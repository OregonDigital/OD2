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

    return approve_collection(collection_id) if collection_id.present?

    approve_everything
  end

  def approve_everything
    migration_user = Hyrax::Migrator.config.migration_user
    solr_query = deposited_by_admin_query(migration_user)
    approve(solr_query)
  end

  def approve_collection(collection_id)
    migration_user = Hyrax::Migrator.config.migration_user
    solr_query = deposited_by_admin_in_collection_query(migration_user, collection_id)
    approve(solr_query)
  end

  def approve(solr_query)
    ActiveFedora::SolrService.query(solr_query, fl: 'id', rows: 10_000).map { |x| x['id'] }.each do |pid|
      item = ActiveFedora::Base.find(pid)
      entity = item.to_sipity_entity
      next if entity.nil? || entity.workflow_state_name != 'pending_review'

      activate_asset(item, entity)
    rescue StandardError => e
      puts "Unable to approve #{pid}: Error: #{e.message} : #{e.backtrace}"
    end
  end

  def activate_asset(item, entity)
    Hyrax::Workflow::ActivateObject.call(target: item)
    deposited = entity.workflow.workflow_states.find_by(name: 'deposited')
    entity.workflow_state_id = deposited.id
    entity.save!
    item.save!
  end

  def deposited_by_admin_query(migration_user)
    "suppressed_bsi:true AND depositor_ssim:#{migration_user}"
  end

  def deposited_by_admin_in_collection_query(migration_user, collection_id)
    "suppressed_bsi:true AND depositor_ssim:#{migration_user} AND member_of_collection_ids_ssim:#{collection_id}"
  end
end
