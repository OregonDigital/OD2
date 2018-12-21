# frozen_string_literal:true

module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Generic
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)

    self.required_fields = %i[title resource_type rights_statement]

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - required_fields)
    end

    def secondary_terms
      []
    end
  end
end
