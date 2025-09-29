# frozen_string_literal:true

module OregonDigital
  # Provide select options for the accessibility feature (:accessibilityFeature) field
  class AccessibilityFeatureService < Hyrax::QaSelectService
    def initialize
      super('accessibility_feature')
    end

    def all_labels(values)
      @authority.all.select { |r| values.include?(r[:id]) }.map { |hash| hash['label'] }
    end

    def select_sorted_all_options
      select_all_options.sort
    end
  end
end
