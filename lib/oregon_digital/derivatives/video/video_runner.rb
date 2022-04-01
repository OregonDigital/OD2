# frozen_string_literal:true

module OregonDigital::Derivatives::Video
  # Tells hydra which processor to use for graphicsmagick processing
  class VideoRunner < Hydra::Derivatives::VideoDerivatives
    def self.processor_class
      OregonDigital::Derivatives::Video::VideoProcessor
    end
  end
end
