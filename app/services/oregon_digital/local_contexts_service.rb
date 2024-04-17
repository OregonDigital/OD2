# frozen_string_literal: true

module OregonDigital
  # CLASS: Local Context Service to provide select options for the local context (dcterms:rights) field
  class LocalContextsService < Hyrax::QaSelectService
    # METHOD: Override the intialize with using the YML file
    def initialize
      super('local_contexts')
    end

    # METHOD: Get all the labels from the 'uri' ids
    def all_labels(values)
      @authority.all.select { |r| values.include?(r[:id]) }.map { |hash| hash['label'] }
    end

    # METHOD: Sort all the options/choices
    def select_sorted_all_options
      select_all_options.sort
    end

    # METHOD: Parse out the label to get an array for the image location
    def parse_labels_for_image(local_contexts_label)
      # VARIABLE: Create an array to store the image location
      local_contexts_arr = []

      # LOOP: Loop through and parse out the label to get the image path
      local_contexts_label.map do |lc|
        local_contexts_arr << if lc.include?('(')
                                lc[/\((.*?)\)/, 1].gsub(' ', '_').downcase
                              else
                                lc.gsub(' ', '_').downcase
                              end
      end

      # RETURN: Return back the parse out content for image path
      local_contexts_arr
    end

    # rubocop:disable Metrics/MethodLength
    # METHOD: Get the size of how many indicator to create for carousel
    def get_carousel_indicator_size(lc_size)
      # VARIABLE: Store the total indicators
      indicator = 0

      # CONDITION: Check the condition to make the size of the indicator to fit the display
      if lc_size <= 4
        indicator += 1
      elsif (lc_size % 4).zero?
        indicator = (lc_size / 4)
      else
        tmp = lc_size
        tmp += 1 while tmp % 4 != 0
        indicator = (tmp / 4)
      end

      # RETURN: Return the total size of indicators
      indicator
    end
    # rubocop:enable Metrics/MethodLength
  end
end
