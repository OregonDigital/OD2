# frozen_string_literal: true

module OregonDigital
  # Provide select options for the license (dcterms:rights) field
  class LicenseService < Hyrax::QaSelectService
    def initialize
      super('licenses')
    end

    def all_labels(values)
      @authority.all.select { |r| values.include?(r[:id]) }.map { |hash| hash['label'] }
    end

    def select_sorted_all_options
      select_all_options.sort
    end
  end
end
