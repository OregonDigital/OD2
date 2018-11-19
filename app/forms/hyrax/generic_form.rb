# Generated via
#  `rails generate hyrax:work Generic`
module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    include OregonDigital::GenericFormBehavior
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Generic
    self.terms += [:resource_type, :oembed_url]
  end
end
