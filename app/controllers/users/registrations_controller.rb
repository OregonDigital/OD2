# frozen_string_literal: true

require 'mail'

# This class handles registering users.
# When it receives an email from a university it redirects
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_if_university, only: [:create]

  protected

  def redirect_if_university
    service = OregonDigital::UserAttributeService.new(params[:user])
    redirect_path = service.email_redirect_path
    redirect_to redirect_path unless redirect_path.nil?
  end
end
