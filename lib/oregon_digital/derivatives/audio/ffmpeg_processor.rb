# frozen_string_literal:true

module OregonDigital::Derivatives::Audio
  # GraphicsMagick processor for derivatives
  class FfmpegProcessor < Hydra::Derivatives::Processors::Audio
    # returns a hash of options that the specific processors use
    def options_for(_format)
      {
        Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => '',
        Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => '-ar 22050 -b:a 96K'
      }
    end
  end
end