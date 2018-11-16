# Generated via
#  `rails generate hyrax:work Generic`
module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    include OD2::GenericFormBehavior
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Generic
  end
end
