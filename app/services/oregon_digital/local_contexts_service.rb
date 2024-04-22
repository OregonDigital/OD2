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
    # METHOD: Get the size of how many rows to create for carousel
    def get_row_size(lc_size)
      # VARIABLE: Store the total rows
      rows = 0

      # CONDITION: Check the condition to make the size of the row to fit the display
      if lc_size <= 4
        rows += 1
      elsif (lc_size % 4).zero?
        rows = (lc_size / 4)
      else
        tmp = lc_size
        tmp += 1 while tmp % 4 != 0
        rows = (tmp / 4)
      end

      # RETURN: Return the total size of rows
      rows
    end
    # rubocop:enable Metrics/MethodLength

    # METHOD: Use to split label array into smaller chunk to display in carousel
    def split_array_chunk(label_arr)
      # VARIABLE: Setup the item needed to store the content
      lc_arr = []
      tmp_arr = []

      # LOOP: Now loop through and split out junk of the array into smaller size and store it in a nested array
      label_arr.each_with_index do |value, index|
        # MOVE: Copy value into the tmp array
        tmp_arr << value

        # CONDITION: Check to make sure we can split it into smaller array by 4 elements
        if ((index + 1) % 4).zero? || index == (label_arr.length - 1)
          lc_arr << tmp_arr
          tmp_arr = []
        end
      end

      # RETURN: Return the nested array to use for carousel
      lc_arr
    end
  end
end
