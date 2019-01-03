# frozen_string_literal:true

module OregonDigital
  # This controller sets up the dashboard configuration for the oembed management system.
  class OembedsController < ApplicationController
    attr_accessor :curation_concern
    helper_method :curation_concern
    load_and_authorize_resource class: ActiveFedora::Base, instance_name: :curation_concern

    def index
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'oregon_digital.oembeds.index.manage_oembeds'), Rails.application.routes.url_helpers.oembeds_path

      @errors = OembedError.all
    end

    def edit
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'oregon_digital.oembeds.index.manage_oembeds'), Rails.application.routes.url_helpers.oembeds_path
      add_breadcrumb t(:'oregon_digital.oembeds.edit.oembed_update'), '#'
    end

    # This is an override of Hyrax::ApplicationController
    def deny_access(exception)
      redirect_to root_path, alert: exception.message
    end

    with_themed_layout 'dashboard'
  end
end
