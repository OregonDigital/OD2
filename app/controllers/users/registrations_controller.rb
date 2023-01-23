# frozen_string_literal: true

# This class handles registering users.
# When it receives an email from a university it redirects
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_create_if_university, only: [:create]
  before_action :redirect_edit_if_university, only: [:edit]

  # OVERRIDE from hyrax to add in mailer.
  # rubocop:disable Metrics/AbcSize
  def destroy
    previous_url = Rails.application.routes.recognize_path(request.referrer)
    admin_delete_request = previous_url[:controller] == 'hyrax/dashboard/profiles' && previous_url[:action] == 'edit'
    if admin_delete_request
      resource = User.find(params['user_id'])
      @user = resource
    end

    OregonDigital::DeleteUserMailer.delete_user(resource).deliver_now
    resource.deactivated = true
    resource.save
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name) unless admin_delete_request
    set_flash_message! :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
  end
  # rubocop:enable Metrics/AbcSize

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
