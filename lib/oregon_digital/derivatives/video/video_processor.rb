# frozen_string_literal:true

module OregonDigital::Derivatives
  module Video
    # Sets output options for video derivatives
    class VideoProcessor < Hydra::Derivatives::Processors::Video::Processor
      protected

      def options_for(_format)
        video = FFMPEG::Movie.new(source_path)
        video_bitrate = [video.video_bitrate, 3_500_000].min
        audio_bitrate = [video.audio_bitrate, 3_500_000].min unless video.audio_bitrate.nil?
        input_options = ''
        output_options = "-c:v libx264 -c:a copy -b:v #{video_bitrate}"
        output_options += " -b:a #{audio_bitrate}" unless video.audio_bitrate.nil?
        output_options += ' -filter:v "scale=\'min(1280,iw)\':min\'(720,ih)\':force_original_aspect_ratio=decrease" -fpsmax 30'

        { Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => output_options, Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => input_options }
      end
    end
  end
end
