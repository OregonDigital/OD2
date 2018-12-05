class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cas
    get_user_and_redirect
  end

  def saml
    get_user_and_redirect
  end

  private

    def get_user_and_redirect
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: request.env["omniauth.auth"].provider.to_s) if is_navigational_format?
    end
end