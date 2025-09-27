# frozen_string_literal: true

module Bulkrax
  # Object factory
  class OregonDigitalObjectFactory < ObjectFactory
    # Override to add the _attributes properties
    def permitted_attributes
      attribute_properties + oembed_attribute + accessibility_attributes + super
    end

    # Gather the attribute_properties
    def attribute_properties
      klass.properties.keys.map { |k| "#{k}_attributes".to_sym unless klass.properties[k].class_name.nil? }.compact
    end

    def oembed_attribute
      [:oembed_urls]
    end

    def accessibility_attributes
      [:accessibility_feature, :accessibility_summary]
    end
  end
end
