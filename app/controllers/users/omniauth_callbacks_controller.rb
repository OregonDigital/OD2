# frozen_string_literal: true

# This handles the omniauth callback to grab a user and sign them in
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[saml failure]

  def cas
    find_user_and_redirect
  end

  def saml
    find_user_and_redirect
  end

  private

  # rubocop:disable Metrics/AbcSize
  def find_user_and_redirect
    @user = User.from_omniauth(request.env['omniauth.auth'])
    prov = request.env['omniauth.auth'].provider.to_s
    sign_in(resource_name, resource)
    redirect_to request.env['omniauth.origin'] || '/'
    set_flash_message(:notice, :success, kind: prov) if is_navigational_format?
  end
  # rubocop:enable Metrics/AbcSize
end
