# frozen_string_literal: true

##
# The job responsible for bulk approving
class BulkApproveJob < OregonDigital::ApplicationJob
  queue_as :hyrax_migrator

  def perform(args)
    bulk_approve(args)
  end

  private

  def bulk_approve(args)
    collection_id = args[:collection_id]
    user = args[:user]
    pid = args[:pid]

    return approve_collection(collection_id, user) if collection_id.present?

    return approve_item(pid) if pid.present?

    approve_everything(user)
  end

  def approve_everything(user)
    solr_query = deposited_by_admin_query(user)
    approve(solr_query)
  end

  def approve_collection(collection_id, user)
    solr_query = deposited_by_admin_in_collection_query(user, collection_id)
    approve(solr_query)
  end

  def approve_item(pid)
    item = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid)
    entity = Sipity::Entity(item)
    return if entity.nil? || entity.workflow_state_name != 'pending_review'

    activate_asset(item, entity)
  rescue StandardError => e
    Rails.logger.error "Unable to approve #{pid}: Error: #{e.message} : #{e.backtrace}"
  end

  def approve(solr_query)
    Hyrax::SolrService.query(solr_query, fl: 'id', rows: 10_000).map { |x| x['id'] }.each do |pid|
      item = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid, use_valkyrie: false)
      entity = Sipity::Entity(item)
      next if entity.nil? || entity.workflow_state_name != 'pending_review'

      activate_asset(item, entity)
    rescue StandardError => e
      Rails.logger.error "Unable to approve #{pid}: Error: #{e.message} : #{e.backtrace}"
    end
  end

  def activate_asset(item, entity)
    Hyrax::Workflow::ActivateObject.call(target: item)
    deposited = entity.workflow.workflow_states.find_by(name: 'deposited')
    entity.workflow_state_id = deposited.id
    entity.save!
    item.save
    # Enable once all model objects are fully valkyrized and indexing works again
    # Hyrax.persister.save(resource: item)
    # Hyrax.index_adapter.save(resource: item)
  end

  def deposited_by_admin_query(user)
    "suppressed_bsi:true AND depositor_ssim:#{user}"
  end

  def deposited_by_admin_in_collection_query(user, collection_id)
    "suppressed_bsi:true AND depositor_ssim:#{user} AND member_of_collection_ids_ssim:#{collection_id}"
  end
end
