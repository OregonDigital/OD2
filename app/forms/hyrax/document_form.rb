# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  # Generated form for Document
  class DocumentForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::DocumentFormBehavior

    self.model_class = ::Document
  end
end
