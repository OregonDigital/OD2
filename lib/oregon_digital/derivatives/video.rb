# frozen_string_literal: true

# Contains video-specific derivative logic
module OregonDigital::Derivatives::Video
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :VideoProcessor
    autoload :VideoRunner
  end
end
