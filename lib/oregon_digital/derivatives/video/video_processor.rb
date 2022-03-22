module Hydra::Derivatives::Processors
  module Video
    class VideoProcessor < Hydra::Derivatives::Processors::Processor
      include Ffmpeg
      
      class_attribute :config
      self.config = Config.new
      
      protected
      
      def options_for(format)
        input_options = ""
        output_options = "-c:v libx264 -fpsmax 30 -b:v 3500K -vf \"scale='-1:'min(720,ih)'\""
      
        if format == "jpg"
          input_options += " -itsoffset -2"
          output_options += " -vframes 1 -an -f rawvideo"
        else
          output_options += " #{config.video_attributes} #{config.audio_attributes}"
        end
      
        { Ffmpeg::OUTPUT_OPTIONS => output_options, Ffmpeg::INPUT_OPTIONS => input_options }
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