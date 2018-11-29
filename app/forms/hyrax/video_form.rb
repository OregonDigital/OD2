# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Video
    self.terms += OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym)

    def primary_terms
      required_fields + OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym) + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - [:dcmi_type]) 
    end
  end
end
