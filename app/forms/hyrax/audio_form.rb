# Generated via
#  `rails generate hyrax:work Audio`
module Hyrax
  # Generated form for Audio
  class AudioForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.required_fields = [:title, :dcmi_type, :rights_statement]
    self.model_class = ::Audio

    def primary_terms
      OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) + [:title, :rights_statement]
    end

    def secondary_terms
      []
    end
  end
end
