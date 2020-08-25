# frozen_string_literal: true

# This class processes users who are trying to login.
# It redirects if it receives an university email
class Users::SessionsController < Devise::SessionsController
  before_action :redirect_if_university, only: [:create]

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: '/'
  end

  protected

  def redirect_if_university
    service = OregonDigital::UserAttributeService.new(params[:user])
    redirect_path = service.email_redirect_path
    redirect_to redirect_path unless redirect_path.nil?
  end
end
