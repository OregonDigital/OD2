# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  # Generated form for Image
  class ImageForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm
    include ::OregonDigital::ImageFormBehavior
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.required_fields = [:title, :dcmi_type, :rights_statement]
    self.model_class = ::Image

    def primary_terms
      required_fields + OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym) +(OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - [:dcmi_type])
    end

    def secondary_terms
      []
    end
  end
end
