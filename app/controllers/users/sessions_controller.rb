# frozen_string_literal: true

require 'mail'

# This class processes users who are trying to login.
# It redirects if it receives an university email
class Users::SessionsController < Devise::SessionsController
  before_action :redirect_if_university, only: [:create]

  protected

  def redirect_if_university
    service = OregonDigital::UserAttributeService.new(params[:user])
    redirect_path = service.email_redirect_path
    redirect_to redirect_path unless redirect_path.nil?
  end
end
