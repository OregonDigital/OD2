# frozen_string_literal: true

module OregonDigital
  # date ops for form
  module IndexingDatesBehavior
    extend ActiveSupport::Concern

    def generate_solr_document
      super.tap do |solr_doc|
        index_date_combined_label(solr_doc)
      end
    end

    private

    # Parse all the data metadata in EDTF format and coalesce into two solr fields to be used
    # as a year range facet and decade facet
    # rubocop:disable Metrics/AbcSize
    def index_date_combined_label(solr_doc)
      solr_doc['date_combined_year_label_ssim'] = []
      solr_doc['date_combined_decade_label_ssim'] = []

      date_combined_fields.each do |date_field|
        next unless object.respond_to? date_field

        solr_doc['date_combined_year_label_ssim'] += date_facet_yearly(object[date_field])
        solr_doc['date_combined_decade_label_ssim'] += decades(object[date_field])
      end

      solr_doc['date_combined_year_label_ssim'].uniq!
      solr_doc['date_combined_decade_label_ssim'].uniq!
      solr_doc['date_combined_year_label_sim'] = solr_doc['date_combined_year_label_ssim']
      solr_doc['date_combined_decade_label_sim'] = solr_doc['date_combined_decade_label_ssim']
    end
    # rubocop:enable Metrics/AbcSize

    # The metadata fields to be combined into one date/decade facet
    def date_combined_fields
      %i[award_date date_created collected_date date issued view_date]
    end

    # date_facet_yearly is intended to be used for date_facet_yearly_ssim, which is used by the facet provided
    # by the interactive Blacklight Range Limit widget
    # date_facet_yearly is expected to return an array of yearly date values like [1910, 1911, 1912]
    # If given date_value = invalid date, i.e. "typo_here2011-12-01", we will get nil
    def date_facet_yearly(date_values)
      return [] if yearly_dates(date_values).empty?

      yearly_dates(date_values)
    rescue ArgumentError => e
      Rails.logger.warn e.message
      return []
    end

    # decades is intended to be used for date_decades_ssim, which is used by the decade facet
    # decades is expected to return an array of year ranges like ["1910-1919", "1920-1929"]
    # here are some examples:
    #  a) given date_value = "2017-12-01", we will get ["2010-2019"]
    #  b) given date_value = "2017-12", we will get ["2010-2019"]
    #  c) given date_value = "2017", we will get ["2010-2019"]
    #  d) given date_value = "2017-2018", we will get ["2010-2019"]
    #  e) given date_value = "2010-2020", we will get ["2010-2019", "2020-2029"]
    #  f) given date_value = "1900-1940", we will get nil
    #  g) given date_value = invalid date, i.e. "typo_here2011-12-01", we will get nil
    def decades(date_values)
      return [] if decade_dates(date_values).empty?

      decade_dates(date_values).map(&:decade)
    rescue ArgumentError => e
      Rails.logger.warn e.message
      return []
    end

    # yearly_dates returns an array of years given a valid date_value. Here are some examples:
    #  a) given date_value = "2017-12-01", we will get [2017]
    #  b) given date_value = "2017-12", we will get [2017]
    #  c) given date_value = "2017", we will get [2017]
    # it also works with ranges and special dates in the ISO 8601 format:
    #  d) given date_value = "2017-12-01/2019-12-01", we will get [2017, 2018, 2019]
    #  e) given date_value = "2017-12/2019-12", we will get [2017, 2018, 2019]
    #  f) given date_value = "2017/2019", we will get [2017, 2018, 2019]
    def yearly_dates(date_values)
      date_values ? clean_years(date_values) : []
    end

    def clean_years(date_values)
      date_values.map do |date_value|
        date = Date.edtf(date_value)
        if date.instance_of? EDTF::Interval
          date.map(&:year).uniq
        elsif date.instance_of? Date
          Array.wrap(date.year)
        else
          parsed_year ? Array.wrap(parsed_year) : []
        end
      end.flatten.uniq
    end

    def decade_dates(date_values)
      return [] unless date_values

      dates = []
      date_values.each do |date_value|
        date = DateDecadeConverter.new(date_value).run
        date ||= Array.wrap(DecadeDecorator.new(parsed_year(date_value))) if parsed_year(date_value)
        dates += date if date
      end
      dates
    end

    def parsed_year(date_value)
      clean_datetime(date_value)&.year
    end

    def clean_datetime(date_value)
      if date_value =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ # YYYY-MM-DD
        DateTime.strptime(date_value, '%Y-%m-%d')
      elsif date_value =~ /^[0-9]{4}-[0-9]{2}$/ # YYYY-MM
        DateTime.strptime(date_value, '%Y-%m')
      elsif date_value =~ /^[0-9]{4}/ # YYYY
        DateTime.strptime(date_value.split('-').first, '%Y')
      else
        Rails.logger.warn "Invalid date_value: #{date_value}. Acceptable formats: YYYY-MM-DD, YYYY-MM, YYYY."
        return nil
      end
    end

    # Date decorator
    class DecadeDecorator
      attr_accessor :year
      def initialize(year)
        @year = year
      end

      def decade
        "#{first_year}-#{last_year}"
      end

      private

      def first_year
        year - year % 10
      end

      def last_year
        year + 10 - (year + 10) % 10 - 1
      end
    end

    # Used for processing decades given a date and generates an array of decorated items using DecadeDecorator
    # when calling run. Expected input dates: "2017-12-01", "2017-12", "2017", "2017-2018", "2010-2020", "1900-1940"
    class DateDecadeConverter
      attr_accessor :date
      def initialize(date)
        @date = date
      end

      def run
        return nil unless valid_date_range?

        decades.times.map do |decade|
          DecadeDecorator.new(earliest_date + 10 * decade)
        end
      end

      private

      def earliest_date
        @earliest_date ||= dates.first - dates.first % 10
      end

      def valid_decade_size?
        decades <= 3
      end

      def valid_date_range?
        dates.first.to_s.length == 4 && dates.last.to_s.length == 4 && dates.length == 2
      end

      def dates
        @dates ||= date.to_s.split('-').map(&:to_i)
      end

      def decades
        calculated_decades = (dates.last - dates.first) / 10 + 1
        calculated_decades <= 3 ? calculated_decades : 0
      end
    end
  end
end
