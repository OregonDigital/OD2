# frozen_string_literal:true

module Hyrax
  # This object sets up the form to display the proper fields
  # as well as applies any necessary behavior we want the form to include
  class ImageForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm
    self.model_class = ::Image
    self.terms += OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym)

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields + (self.terms - required_fields)
    end

    def secondary_terms
      []
    end
  end
end
