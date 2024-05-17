# frozen_string_literal:true

module OregonDigital
  # Sets controlled properties behaviors for all works
  module ControlledPropertiesBehavior
    extend ActiveSupport::Concern

    included do
      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties

      # Sets controlled values
      self.controlled_properties = properties.select { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys.map(&:to_sym)

      # Allows for the controlled properties to accept nested data
      controlled_properties.each do |prop|
        accepts_nested_attributes_for prop, reject_if: id_blank, allow_destroy: true
      end

      # defines a method to be able to grab a list of properties
      define_singleton_method :controlled_property_labels do
        remote_controlled_props = controlled_properties.each_with_object([]) { |prop, array| array << "#{prop}_label" }
        file_controlled_props = %w[license_label local_contexts_label]
        (remote_controlled_props + file_controlled_props).freeze
      end
    end
  end
end
