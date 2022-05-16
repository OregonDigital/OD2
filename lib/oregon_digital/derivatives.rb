# frozen_string_literal: true

# Contains logic for generating custom derivatives the OD way
module OregonDigital::Derivatives
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Audio
    autoload :Document
    autoload :Image
    autoload :Video
  end
end
