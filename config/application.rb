# frozen_string_literal: true

require_relative 'boot'
require 'logger'
require 'rails/all'
require 'triplestore_adapter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OD2
  # Sets application wide config
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += %W[#{config.root}/lib]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.to_prepare do
      BlacklightAdvancedSearch::AdvancedController.prepend OregonDigital::AdvancedControllerIndex
    end
  end
end
