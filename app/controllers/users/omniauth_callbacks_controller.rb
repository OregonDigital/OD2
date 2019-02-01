# frozen_string_literal: true

# This handles the omniauth callback to grab a user and sign them in
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:saml, :failure]

  def cas
    find_user_and_redirect
  end

  def saml
    find_user_and_redirect
  end

  private

  def find_user_and_redirect
    @user = User.from_omniauth(request.env['omniauth.auth'])
    prov = request.env['omniauth.auth'].provider.to_s
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: prov) if is_navigational_format?
  end
end
