# frozen_string_literal: true

# Application wide helper to help access blacklight catalog configuration
module CatalogHelper
  include Blacklight::CatalogHelperBehavior
  # OVERRIDE FROM BLACKLIGHT to add custom configuration helper behaviors
  include OregonDigital::ConfigurationHelperBehavior
end
