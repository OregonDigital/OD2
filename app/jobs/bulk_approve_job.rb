# frozen_string_literal: true

##
# The job responsible for bulk approving
class BulkApproveJob < OregonDigital::ApplicationJob
  def perform(args)
    bulk_approve(args)
  end

  private

  def bulk_approve(args)
    collection_id = args[:collection_id]
    pidlist = args[:pid_list]
    user = args[:user]

    return approve_collection(collection_id, user) if collection_id.present?

    return approve_list(pidlist) if pidlist.present?

    approve_everything(user)
  end

  def approve_everything(user)
    solr_query = deposited_by_admin_query(user)
    approve_query(solr_query)
  end

  def approve_collection(collection_id, user)
    solr_query = deposited_by_admin_in_collection_query(user, collection_id)
    approve_query(solr_query)
  end

  def approve_list(pidlist)
    File.readlines(pidlist).each do |pid|
      approve(pid.strip)
    end
  end

  def approve_query(solr_query)
    Hyrax::SolrService.query(solr_query, fl: 'id', rows: 10_000).map { |x| x['id'] }.each do |pid|
      approve(pid)
    end
  end

  def approve(pid)
    item = ActiveFedora::Base.find(pid)
    entity = item.to_sipity_entity
    return if entity.nil? || entity.workflow_state_name != 'pending_review'

    activate_asset(item, entity)
  rescue StandardError => e
    Rails.logger.error "Unable to approve #{pid}: Error: #{e.message} : #{e.backtrace}"
  end

  def activate_asset(item, entity)
    Hyrax::Workflow::ActivateObject.call(target: item)
    deposited = entity.workflow.workflow_states.find_by(name: 'deposited')
    entity.workflow_state_id = deposited.id
    entity.save!
    item.save!
  end

  def deposited_by_admin_query(user)
    "suppressed_bsi:true AND depositor_ssim:#{user}"
  end

  def deposited_by_admin_in_collection_query(user, collection_id)
    "suppressed_bsi:true AND depositor_ssim:#{user} AND member_of_collection_ids_ssim:#{collection_id}"
  end
end
