# frozen_string_literal: true

module Hyrax
  # Behavior to prevent unauthorized users from accessing the dashboard
  module DashboardAuthorization
    extend ActiveSupport::Concern

    included do
      prepend_before_action :dashboard_authorization
    end

    def dashboard_authorization
      response_code = user_signed_in? ? 403 : 401
      render(file: File.join("public/#{response_code}.html"), status: response_code, layout: false) unless current_user&.role?(::Ability.manager_permission_roles)
    end
  end
end
