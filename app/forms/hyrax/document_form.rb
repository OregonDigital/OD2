# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  # Generated form for Document
  class DocumentForm < Hyrax::Forms::WorkForm
    self.model_class = ::Document
    self.terms += [:resource_type]
  end
end
