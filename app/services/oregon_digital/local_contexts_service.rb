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
  end
end
