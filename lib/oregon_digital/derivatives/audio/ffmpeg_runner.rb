# frozen_string_literal:true

module OregonDigital::Derivatives::Audio
  # Tells hydra which processor to use for graphicsmagick processing
  class FfmpegRunner < Hydra::Derivatives::AudioDerivatives
    def self.processor_class
      OregonDigital::Derivatives::Audio::FfmpegProcessor
    end
  end
end
