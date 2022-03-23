module OregonDigital::Derivatives
  module Video
    class VideoProcessor < Hydra::Derivatives::Processors::Video::Processor
      
      protected
      
      def options_for(format)
        input_options = ""
        output_options = "-c:v libx264 -filter:v fps=fps=30 -filter:v \"scale='min(1280,iw)':min'(720,ih)':force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2\" -b:v 3500K-c:v libx264 -filter:v fps=fps=30 -b:v 3500K"
      
        { Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => output_options, Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => input_options }
      end
      
      def codecs(format)
        case format
        when 'mp4'
          config.mpeg4.codec
        when 'webm'
          config.webm.codec
        when "mkv"
          config.mkv.codec
        when "jpg"
          config.jpeg.codec
        else
          raise ArgumentError, "Unknown format `#{format}'"
        end
      end
    end
  end
end