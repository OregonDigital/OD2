# frozen_string_literal: true

module OregonDigital
  # Autoloads controlled vocabulary objects
  module ControlledVocabularies
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :MediaType
    end
  end
end
