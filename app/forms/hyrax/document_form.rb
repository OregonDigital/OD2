# frozen_string_literal:true

module Hyrax
  # This object sets up the form to display the proper fields
  # as well as applies any necessary behavior we want the form to include
  class DocumentForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Document
    self.terms += OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym)

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields + OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym) + (OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) - required_fields)
    end
  end
end
