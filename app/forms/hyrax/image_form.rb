# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  # Generated form for Image
  class ImageForm < Hyrax::Forms::WorkForm
    self.model_class = ::Image
    self.terms += [:resource_type, :colour_content, :color_space, :height, :orientation, :photograph_orientation, :resolution, :view, :width]
  end
end
