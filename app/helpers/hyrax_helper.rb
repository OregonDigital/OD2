# frozen_string_literal:true

# Application wide helper to contain hyrax based methods
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
end
