# frozen_string_literal: true

# Contains audio-specific derivative logic
module OregonDigital::Derivatives::Audio
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :FfmpegProcessor
    autoload :FfmpegRunner
  end
end
