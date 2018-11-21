# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::VideoFormBehavior

    self.model_class = ::Video
  end
end
