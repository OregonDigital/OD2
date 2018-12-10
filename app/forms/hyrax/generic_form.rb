# frozen_string_literal:true

module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Generic
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)

    self.required_fields = %i[title dcmi_type rights_statement]

    def primary_terms
      required_fields + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - [:dcmi_type])
    end

    def secondary_terms
      []
    end
  end
end
