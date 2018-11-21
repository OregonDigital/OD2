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

  # Append some data into Honeycomb events to support tracing
  if %w[production staging].include? Rails.env
    def append_info_to_payload(payload)
      super(payload)
      honeycomb_metadata["trace.trace_id"] = request.request_id
      honeycomb_metadata["trace.span_id"] = request.request_id
      honeycomb_metadata[:service_name] = "rails"
      honeycomb_metadata[:request_id] = request.request_id
      honeycomb_metadata[:request_uuid] = request.uuid
      honeycomb_metadata[:name] = self.class.name
    end
  end
end
