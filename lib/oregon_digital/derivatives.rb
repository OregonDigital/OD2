# frozen_string_literal: true

# Contains logic for generating custom derivatives the OD way
module OregonDigital::Derivatives
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Image
    autoload :Document
  end
end
