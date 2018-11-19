# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  # Generated form for Document
  class DocumentForm < Hyrax::Forms::WorkForm
    # include OD2::GenericFormBehavior
    include OD2::VideoFormBehavior
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Document
  end
end
