module OregonDigital
  module OembedsControllerBehavior
    extend ActiveSupport::Concern

    def index
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'oregon_digital.oembeds.index.manage_oembeds'), Rails.application.routes.url_helpers.oembeds_path
    end
  end
end
