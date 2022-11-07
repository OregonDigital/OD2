# frozen_string_literal: true

module Hyrax
  # Behavior to prevent unauthorized users from accessing the dashboard
  module DashboardAuthorization
    extend ActiveSupport::Concern

    included do
      prepend_before_action :dashboard_authorization
    end

    def dashboard_authorization
      render(file: File.join('public/401.html'), status: 401, layout: false) unless current_user&.role?(::Ability.manager_permission_roles)
    end
  end
end
