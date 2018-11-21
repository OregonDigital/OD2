# Generated via
#  `rails generate hyrax:work Generic`
module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Generic
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)

    self.required_fields = []

    def primary_terms
      OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) + [:keyword, :title]
    end
  end
end
