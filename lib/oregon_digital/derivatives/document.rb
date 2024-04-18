# frozen_string_literal: true

# Contains document-specific derivative logic
module OregonDigital::Derivatives::Document
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Processor
    autoload :Runner
    autoload :TesseractProcessor
    autoload :TesseractRunner
  end
end
