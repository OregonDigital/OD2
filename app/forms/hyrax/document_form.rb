# frozen_string_literal:true

module Hyrax
  # This object sets up the form to display the proper fields
  # as well as applies any necessary behavior we want the form to include
  class DocumentForm < Hyrax::GenericForm
    self.model_class = ::Document
    self.terms += Document.document_properties.map(&:to_sym)
    self.terms = Generic::ORDERED_TERMS
  end
end
