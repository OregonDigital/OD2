# Generated via
#  `rails generate hyrax:work Audio`
module Hyrax
  # Generated form for Audio
  class AudioForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.model_class = ::Audio

    self.required_fields = []

    def primary_terms
      OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) + [:keyword, :title]
    end
  end
end
