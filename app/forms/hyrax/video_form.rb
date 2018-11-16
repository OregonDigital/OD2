# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::Forms::WorkForm
    include OD2::GenericFormBehavior
    include OD2::VideoFormBehavior
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Video
  end
end
