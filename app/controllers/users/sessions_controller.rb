# frozen_string_literal: true

# This class processes users who are trying to login.
# It redirects if it receives an university email
class Users::SessionsController < Devise::SessionsController
  before_action :redirect_if_university, only: [:create]

  # rubocop:disable Metrics/AbcSize
  def create
    user = User.find_by_email params[:user]['email']
    set_flash_message!(:alert, :deactivated) if user&.deactivated?
    return redirect_back fallback_location: '/' if user&.deactivated?

    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
  # rubocop:enable Metrics/AbcSize

  protected

  def redirect_if_university
    unless params[:user].nil?
      service = OregonDigital::UserAttributeService.new(params[:user])
      redirect_path = service.email_redirect_path
    end
    redirect_to redirect_path unless redirect_path.nil?
  end
end
