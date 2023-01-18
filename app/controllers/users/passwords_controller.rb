# frozen_string_literal: true

# This class processes users who are trying to manage their password.
# It redirects if it receives an university email
class Users::PasswordsController < Devise::PasswordsController
  before_action :redirect_if_university, only: [:create]

    # POST /resource/password
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    end

  # Helper for use in before_actions where no authentication is required.
  #
  # Example:
  #   before_action :require_no_authentication, only: :new
  def require_no_authentication
    # OVERRIDE DEVISE: Return false early if the previous controller was the admin dashboard
    previous_url = Rails.application.routes.recognize_path(request.referrer)
    return false if previous_url[:controller] == 'hyrax/dashboard/profiles' && previous_url[:action] == 'edit'
    # END OVERRIDE

    assert_is_devise_resource!
    return unless is_navigational_format?
    no_input = devise_mapping.no_input_strategies

    authenticated = if no_input.present?
      args = no_input.dup.push scope: resource_name
      warden.authenticate?(*args)
    else
      warden.authenticated?(resource_name)
    end

    if authenticated && resource = warden.user(resource_name)
      set_flash_message(:alert, 'already_authenticated', scope: 'devise.failure')
      redirect_to after_sign_in_path_for(resource)
    end
  end

  protected

  def redirect_if_university
    service = OregonDigital::UserAttributeService.new(params[:user])
    redirect_path = service.email_redirect_path
    return if redirect_path.nil?

    flash[:error] = 'University members are unable to change their password here. Please refer to instructions provided by your university to change your password.'
    redirect_to new_user_password_path
  end
end
