# frozen_string_literal:true

require 'csv'

module OregonDigital
  # Sets base behaviors for all works
  module WorkBehavior
    extend ActiveSupport::Concern
    include OregonDigital::AccessControls::Visibility

    included do
      validates_presence_of %i[title resource_type rights_statement identifier]
    end

    def graph_fetch_failures
      @graph_fetch_failures ||= []
    end

    # Export work metadata as CSV string
    def csv_metadata(keys, controlled_keys)
      # Build a CSV of label headers and metadata value data
      ::CSV.generate do |csv|
        csv << keys
        csv << metadata_row(keys, controlled_keys)
        child_works.each do |work|
          csv << work.metadata_row(keys, controlled_keys)
        end
      end
    end

    # Export work metadata as a CSV string
    def metadata_row(keys, controlled_keys)
      keys.map do |label|
        values = try(label)
        if values.nil?
        elsif service = local_metadata_authority_service(label)
          values = Array(values).map { |prop| service.label prop }.join('|')
        elsif controlled_keys.include?(label.to_sym)
          values = values.map { |prop| controlled_property_to_csv_value(prop).to_s }.join('|')
        else
          values = (values.respond_to?(:map) ? values.map(&:to_s).join('|') : values)
        end
        values
      end
    end

    private

    def local_metadata_authority_service(key)
      @label_services ||= [
        OregonDigital::LanguageService.new,
        Hyrax.config.license_service_class.new,
        Hyrax::ResourceTypesService,
        Hyrax.config.rights_statement_service_class.new
      ]
      @label_services.each do |service|
        return service if service.authority.subauthority == key.pluralize
      rescue KeyError
      end
      nil
    end

    # Convert work controlled property value to label
    def controlled_property_to_csv_value(prop)
      begin
        prop.fetch
        label = prop.solrize[1][:label].split('$')[0]
      # TriplestoreAdapter::TriplestoreException means no fetch possible
      # NoMethodError likely means the fetch succeeded but no label was actually fetched, this is possible with geonames w/ http
      rescue TriplestoreAdapter::TriplestoreException, NoMethodError
        label = ['No label found', "[#{prop.solrize.first}]"].join(' ')
      end
      label
    end
  end
end
