# frozen_string_literal: true

module Hyrax
  # Behavior to prevent unauthorized users from accessing the dashboard
  module DashboardAuthorization
    extend ActiveSupport::Concern

    included do
      before_action :dashboard_authorization
    end

    def dashboard_authorization
      redirect_to root_path unless current_user&.role?(::Ability.manager_permission_roles)
    end
  end
end
