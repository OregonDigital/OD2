# frozen_string_literal:true

module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Video
    self.terms += OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym)

    def primary_terms
      required_fields + OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym) + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - required_fields)
    end
  end
end
