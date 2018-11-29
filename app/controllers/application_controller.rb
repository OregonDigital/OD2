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

  def append_info_to_payload(payload)
    super(payload)
    Rack::Honeycomb.add_field(request.env, 'version', ENV.fetch('DEPLOYED_VERSION', OregonDigital::VERSION))
    Rack::Honeycomb.add_field(request.env, 'classname', self.class.name)
  end
end
