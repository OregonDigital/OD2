# frozen_string_literal:true

module OregonDigital
  # Finds works that are in review and the user can action on
  # Based on Hyrax::Workflow::StatusListService
  class InReviewSearchBuilder < ::SearchBuilder
    self.default_processor_chain += %i[in_review_ids]
    self.default_processor_chain -= %i[only_active_works]

    # Get all the ids for the works in review from Hyrax and pipe into this search builder
    def in_review_ids(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] = solr_params[:fq] | query
    end

    private

    def query
      ["{!terms f=actionable_workflow_roles_ssim}#{roles_for_user.join(',')}", '-workflow_state_name_ssim:deposited']
    end

    # @return [Array<String>] the list of workflow-role combinations this user has
    def roles_for_user
      Sipity::Workflow.all.flat_map do |wf|
        workflow_roles_for_user_and_workflow(wf).map do |wf_role|
          "#{wf.permission_template.source_id}-#{wf.name}-#{wf_role.role.name}"
        end
      end
    end

    # @param workflow [Sipity::Workflow]
    # @return [ActiveRecord::Relation<Sipity::WorkflowRole>]
    def workflow_roles_for_user_and_workflow(workflow)
      Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: current_ability.current_user, workflow: workflow)
    end
  end
end
