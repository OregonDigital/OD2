# frozen_string_literal: true

# This class handles registering users.
# When it receives an email from a university it redirects
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_create_if_university, only: [:create]
  before_action :redirect_edit_if_university, only: [:edit]

  protected

  def redirect_create_if_university
    redirect_path = insitutional_redirect_page(params[:user])
    return if redirect_path.nil?

    flash[:error] = 'Please sign in through your university below.'
    redirect_to redirect_path
  end

  def redirect_edit_if_university
    redirect_path = insitutional_redirect_page(current_user)
    return if redirect_path.nil?

    flash[:error] = 'University members are unable to change their password here. Please refer to instructions provided by your university to change your password.'
    redirect_to hyrax.dashboard_path
  end

  def insitutional_redirect_page(user)
    service = OregonDigital::UserAttributeService.new(user)
    service.email_redirect_path
  end
end
