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
      admin || operating_on_user_collection
    end

    def admin
      current_user&.role?(::Ability.manager_permission_roles) || current_user&.sipity_agent&.workflow_responsibilities&.count&.positive?
    end

    def operating_on_user_collection
      curation_concern ||= nil
      (params[:collection_type_gid] || curation_concern&.collection_type_gid) == Hyrax::CollectionType.find_by(machine_id: :user_collection)&.gid&.to_s
    end
  end
end
