# frozen_string_literal: true

# Contains logic for generating custom derivatives the OD way
module OregonDigital::AccessControls
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :AccessRight
  end
end
