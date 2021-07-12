# frozen_string_literal: true

# Controller for user email confirmation
class Users::ConfirmationsController < Devise::ConfirmationsController
  # rubocop:disable Metrics/AbcSize
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      # OVERRIDE FROM DEVISE to sign user in after confirming email
      sign_in(resource)
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def after_confirmation_path_for(_resource_name, _resource)
    root_path || super
  end
end
