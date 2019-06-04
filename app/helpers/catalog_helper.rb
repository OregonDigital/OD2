# frozen_string_literal: true
module CatalogHelper
  include Blacklight::CatalogHelperBehavior
  # OVERRIDE FROM BLACKLIGHT to add custom configuration helper behaviors
  include OregonDigital::ConfigurationHelperBehavior
end
