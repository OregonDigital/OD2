# frozen_string_literal:true

module Hyrax
  # This object sets up the form to display the proper fields
  # as well as applies any necessary behavior we want the form to include
  class ImageForm < Hyrax::GenericForm
    self.model_class = ::Image
    self.terms += Image.image_properties.map(&:to_sym)
  end
end
