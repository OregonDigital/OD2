# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::GenericFormBehavior
    include ::OregonDigital::VideoFormBehavior
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Video
  end
end
