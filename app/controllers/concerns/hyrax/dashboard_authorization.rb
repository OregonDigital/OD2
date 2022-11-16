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
      render(file: File.join("public/#{response_code}.html"), status: response_code, layout: false) unless dashboard_allowed
    end

    def dashboard_allowed
      # current user has a managing role || current user has a workflow responsibility || if user is trying to create user_collection
      current_user&.role?(::Ability.manager_permission_roles) || current_user&.sipity_agent&.workflow_responsibilities&.count&.positive? || user_is_creating_collection?
    end

    def user_is_creating_collection?
      controller_name.to_s.include?("collections") && params[:action] == "create" && params[:collection_type_gid] == Hyrax::CollectionType.find_by(machine_id: :user_collection).gid
    end
  end
end
