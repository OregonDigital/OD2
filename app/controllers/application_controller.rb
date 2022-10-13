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

  private

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end
end
