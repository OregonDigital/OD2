# frozen_string_literal:true

module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Video
    self.terms += OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym)

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields + (self.terms - required_fields)
    end
  end
end
