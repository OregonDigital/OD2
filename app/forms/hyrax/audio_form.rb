# frozen_string_literal:true

module Hyrax
  # Generated form for Audio
  class AudioForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm
    self.model_class = ::Audio

    def primary_terms
      required_fields + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - [:dcmi_type])
    end

    def secondary_terms
      []
    end
  end
end
