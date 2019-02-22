# frozen_string_literal:true

module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::GenericForm
    self.model_class = ::Video
    self.terms += OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym)
  end
end
