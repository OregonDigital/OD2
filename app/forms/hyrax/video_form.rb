# frozen_string_literal:true

module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::GenericForm
    self.model_class = ::Video
    self.terms += Video.video_properties.map(&:to_sym)
  end
end
