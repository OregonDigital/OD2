module Hyrax
  class DocumentForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Document
    self.terms += OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym)

    def primary_terms
      required_fields + OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym) + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - [:dcmi_type]) 
    end
  end
end
