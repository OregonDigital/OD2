class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cas
    Rails.logger.info(request.env["omniauth.auth"].provider)

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    puts request.env["omniauth.auth"].provider
    sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
    set_flash_message(:notice, :success, kind: "CAS") if is_navigational_format?
  end

  def shibboleth
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
     sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
    set_flash_message(:notice, :success, kind: "Shibboleth") if is_navigational_format?
  end
end