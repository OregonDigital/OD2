# frozen_string_literal:true

module OregonDigital::Derivatives
  module Video
    # Sets output options for video derivatives
    class VideoProcessor < Hydra::Derivatives::Processors::Video::Processor
      protected

      def options_for(_format)
        input_options = ''
        output_options = "-c:v libx264 -c:a copy -filter:v \"scale='min(1280,iw)':min'(720,ih)':force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=30\" -b:v 3500K -b:a 3500K"

        { Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => output_options, Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => input_options }
      end
    end
  end
end
