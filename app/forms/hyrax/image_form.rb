# frozen_string_literal:true

module Hyrax
  class ImageForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm
    self.model_class = ::Image
    self.terms += OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym)

    def primary_terms
      required_fields + OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym) + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - required_fields)
    end

    def secondary_terms
      []
    end
  end
end
