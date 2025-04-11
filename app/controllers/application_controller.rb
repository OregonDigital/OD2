# frozen_string_literal:true

# This is the base controller of the application. Basic setup for the rest of the app occurs here.
class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController

  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  # Send user to 401/403 page rather than forward with flash message
  rescue_from CanCan::AccessDenied do
    response_code = user_signed_in? ? 403 : 401
    respond_to do |wants|
      wants.json { head :forbidden }
      wants.html { render(file: File.join("public/#{response_code}.html"), status: response_code, layout: false) }
    end
  end

  if %w[production].include? Rails.env
    def append_info_to_payload(payload)
      super(payload)
      Honeycomb.add_field('version', ENV.fetch('DEPLOYED_VERSION', OregonDigital::VERSION))
      Honeycomb.add_field('classname', self.class.name)
    end
  end

  private

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  # - The request is handeled by a controller that must be skipped
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && !storable_skipped_controllers.include?(self.class)
  end

  # Some controllers must be skipped when storing previous visit
  def storable_skipped_controllers
    [
      Hyrax::DownloadsController
    ]
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end
end
