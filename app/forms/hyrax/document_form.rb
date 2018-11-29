# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  # Generated form for Document
  class DocumentForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::DocumentFormBehavior
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.required_fields = [:title, :dcmi_type, :rights_statement]

    self.model_class = ::Document

    def primary_terms
      OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) + [:title, :rights_statement]
    end

    def secondary_terms
      []
    end
  end
end
