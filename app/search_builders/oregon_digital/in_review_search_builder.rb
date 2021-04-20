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
      solr_params[:fq] << "id:(#{solr_documents.map(&:id).join(' OR ')})"
    end

    def solr_documents
      Hyrax::Workflow::StatusListService.new(@scope, '-workflow_state_name_ssim:deposited').each
    end
  end
end
