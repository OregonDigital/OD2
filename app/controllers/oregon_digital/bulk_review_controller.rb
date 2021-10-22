#frozen_string_literal: true

module OregonDigital
  # Bulk Reviews items from the review page
  class BulkReviewController < ApplicationController
    def approve_items
      items_to_review = params[:items_to_review]
      approve(items_to_review)
      redirect_to
    end

    private

    def approve(items_to_review)
      items_to_review.each do |pid|
        item = ActiveFedora::Base.find(pid)
        entity = item.to_sipity_entity
	next if entity.nil? || entity.workflow_state_name != 'pending_review'
	  
	activate_asset(item, entity)
	rescue StandardError => e
	  Rails.logger.error "Unable to approve #{pid}: Error: #{e.message} : #{e.backtrace}"
	end
      end
    end

    def activate_asset(item, entity)
      Hyrax::Workflow::ActivateObject.call(target: item)
      deposited = entity.workflow.workflow_states.find_by(name: 'deposited')
      entity.workflow_state_id = deposited.id
      entity.save!
      item.save!
    end
  end
end