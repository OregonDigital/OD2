# frozen_string_literal:true

module Hyrax
  # This object sets up the form to display the proper fields
  # as well as applies any necessary behavior we want the form to include
  class DocumentForm < Hyrax::GenericForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Document
    self.terms += OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym)
  end
end
