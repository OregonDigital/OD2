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

    # rubocob:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def dashboard_allowed
      # current user has a managing role || current user has a workflow responsibility || if user is trying to create user_collection
      current_user&.role?(::Ability.manager_permission_roles) || current_user&.sipity_agent&.workflow_responsibilities&.count&.positive? || collection_exceptions?
    end
    # rubocob:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    def collection_exceptions?
      user_is_creating_collection? || user_is_updating_collection? || user_is_sharing_collection?
    end

    def user_is_creating_collection?
      (allowed_controllers.include? controller_name.to_s) && (params[:collection_type_gid] == Hyrax::CollectionType.find_by(machine_id: :user_collection).gid.to_s)
    end

    def user_is_updating_collection?
      (controller_name.to_s == 'collection_members') && (params[:collection][:members] == 'add')
    end

    def user_is_sharing_collection?
      (controller_name.to_s == 'collections') && (params[:collection][:visibility].in? ['open', 'restricted'])
    end

    def allowed_controllers
      %w[collections works]
    end
  end
end
