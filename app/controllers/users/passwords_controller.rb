# frozen_string_literal: true

# This class processes users who are trying to manage their password.
# It redirects if it receives an university email
class Users::PasswordsController < Devise::PasswordsController
  before_action :redirect_if_university, only: [:create]

  protected

  def redirect_if_university
    service = OregonDigital::UserAttributeService.new(params[:user])
    redirect_path = service.email_redirect_path
    return if redirect_path.nil?

    flash[:error] = 'University members are unable to change their password here. Please refer to instructions provided by your university to change your password.'
    redirect_to new_user_password_path
  end
end
