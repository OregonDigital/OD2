# frozen_string_literal: true

module Hyrax
  # Presents a list of works in workflow
  class Admin::WorkflowsController < ApplicationController
    # OVERRIDE FROM HYRAX TO: add workflows catalog behavior to allow review queue to use catalog controller configuration
    include Hyrax::Admin::WorkflowsCatalogBehavior
    # END OVERRIDE

    before_action :ensure_authorized!
    with_themed_layout 'dashboard'
    class_attribute :deposited_workflow_state_name

    # Works that are in this workflow state (see workflow json template) are excluded from the
    # status list and display in the "Published" tab
    self.deposited_workflow_state_name = 'deposited'

    def self.configure_facets
      configure_blacklight do |config|
        config.add_facet_field 'depositor_ssim', limit: 5, label: 'Depositor'
        config.add_facet_field 'bulkrax_importer_id_sim', limit: 5, label: 'Importer ID'
      end
    end
    configure_facets

    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyrax.admin.sidebar.tasks'), '#'
      add_breadcrumb t(:'hyrax.admin.sidebar.workflow_review'), request.path
      @status_list = Hyrax::Workflow::StatusListService.new(self, "-workflow_state_name_ssim:#{deposited_workflow_state_name}")
      @published_list = Hyrax::Workflow::StatusListService.new(self, "workflow_state_name_ssim:#{deposited_workflow_state_name}")
      super
    end
    # rubocop:enable Metrics/AbcSize

    private

    def ensure_authorized!
      authorize! :review, :submissions
    end
  end
end
