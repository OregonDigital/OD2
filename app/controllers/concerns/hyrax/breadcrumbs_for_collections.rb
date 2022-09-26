# frozen_string_literal: true
# OVERRIDE FROM HYRAX: To remove some breadcrumbs from non-admin users & fix breadcrumbs for explore_collection
module Hyrax
  module BreadcrumbsForCollections
    extend ActiveSupport::Concern
    include Hyrax::Breadcrumbs

    included do
      before_action :build_breadcrumbs, only: [:edit, :show]
    end

    def build_breadcrumbs
      if request.referer
        trail_from_referer
      else
        default_trail
        add_breadcrumb_for_controller if user_signed_in? && current_user.admin?
        add_breadcrumb_for_action
      end
    end

    def default_trail
      add_breadcrumb I18n.t('hyrax.controls.home'), hyrax.root_path
      add_breadcrumb t('hyrax.controls.explore'), Rails.application.routes.url_helpers.all_collections_path
      add_breadcrumb I18n.t('hyrax.dashboard.title'), hyrax.dashboard_path if user_signed_in? && current_user.admin?
    end

    def add_breadcrumb_for_controller; end

    def add_breadcrumb_for_action
      case action_name
      when 'edit'
        add_breadcrumb I18n.t("hyrax.collection.edit_view"), collection_path(params["id"]), mark_active_action
      when 'show'
        add_breadcrumb I18n.t("hyrax.collection.edit_view"), edit_dashboard_collection_path(params["id"]), mark_active_action if user_signed_in? && current_user.admin?
      end
    end

    def mark_active_action
      { "aria-current" => "page" }
    end
  end
end
