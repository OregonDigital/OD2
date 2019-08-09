# frozen_string_literal:true

# This is the base controller of the application. Basic setup for the rest of the app occurs here.
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  # Hyrax 2.1 migration
  skip_after_action :discard_flash_if_xhr

  protect_from_forgery with: :exception

  if %w[production].include? Rails.env
    def append_info_to_payload(payload)
      super(payload)
      Honeycomb.add_field('version', ENV.fetch('DEPLOYED_VERSION', OregonDigital::VERSION))
      Honeycomb.add_field('classname', self.class.name)
    end
  end
end
