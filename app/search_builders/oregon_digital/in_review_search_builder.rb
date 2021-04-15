# frozen_string_literal:true

module OregonDigital
  # Finds works that are in review and the user can action on
  # Based on Hyrax::Workflow::StatusListService
  class InReviewSearchBuilder < ::SearchBuilder
    self.default_processor_chain += %i[actionable not_deposited]
    self.default_processor_chain -= %i[only_active_works]

    def actionable(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] << "{!terms f=actionable_workflow_roles_ssim}#{actionable_roles.join(',')}"
    end

    def not_deposited(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] << '-workflow_state_name_ssim:deposited'
    end

    # @return [Array<String>] the list of workflow-role combinations this user has
    def actionable_roles
      Sipity::Workflow.all.flat_map do |wf|
        workflow_roles_for_user_and_workflow(wf).map do |wf_role|
          "#{wf.permission_template.source_id}-#{wf.name}-#{wf_role.role.name}"
        end
      end
    end

    # @param workflow [Sipity::Workflow]
    # @return [ActiveRecord::Relation<Sipity::WorkflowRole>]
    def workflow_roles_for_user_and_workflow(workflow)
      Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: @scope.current_user, workflow: workflow)
    end
  end
end
