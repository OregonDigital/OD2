# frozen_string_literal:true

module OregonDigital
  # This controller sets up the dashboard configuration for the oembed management system.
  class OembedsController < ApplicationController
    attr_accessor :curation_concern
    helper_method :curation_concern

    def index
      authorize! :show, Hyrax::Resource

      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'oregon_digital.oembeds.index.manage_oembeds'), Rails.application.routes.url_helpers.oembeds_path

      @errors = OembedError.all
    end

    def edit
      load_curation_concern
      return unless can? :edit, @curation_concern
      # authorize! :edit, @curation_concern

      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'oregon_digital.oembeds.index.manage_oembeds'), Rails.application.routes.url_helpers.oembeds_path
      add_breadcrumb t(:'oregon_digital.oembeds.edit.oembed_update'), '#'
    end

    def load_curation_concern
      @curation_concern = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: params[:id])
    end

    # This is an override of Hyrax::ApplicationController
    def deny_access(exception)
      redirect_to root_path, alert: exception.message
    end

    with_themed_layout 'dashboard'
  end
end
