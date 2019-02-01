# frozen_string_literal: true

module OregonDigital
  # Autoloads controlled vocabulary objects
  module ControlledVocabularies
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :MediaType
      autoload :ExtendedLocation
    end
  end
end
