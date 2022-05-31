# frozen_string_literal:true

module OregonDigital::Derivatives::Audio
  # GraphicsMagick processor for derivatives
  class FfmpegProcessor < Hydra::Derivatives::Processors::Audio
    # returns a hash of options that the specific processors use
    def options_for(_format)
      audio = FFMPEG::Movie.new(source_path)
      audio_bitrate = [audio.audio_bitrate, 96_000].min
      input_options = ''
      # pass mp3s through, all else get a standard sampling rate and bitrate
      output_options = "-ar 44100 -b:a #{audio_bitrate}" if audio.audio_codec != 'mp3'

      { Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => output_options, Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => input_options }
    end
  end
end
