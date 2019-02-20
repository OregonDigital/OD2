# frozen_string_literal: true

# Contains image-specific derivative logic
module OregonDigital::Derivatives::Image
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :GMProcessor
    autoload :GMRunner
    autoload :JP2Processor
    autoload :JP2Runner
    autoload :Utils
  end
end
