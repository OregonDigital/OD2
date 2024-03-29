# frozen_string_literal: true

namespace :migration do
  desc 'Bulk approve migrated items'
  task bulk_approve: :environment do
    puts 'Approving all the things...'
    migration_user = Hyrax::Migrator.config.migration_user
    Hyrax::SolrService.query("suppressed_bsi:true AND depositor_ssim:#{migration_user}", fl: 'id', rows: 10_000).map { |x| x['id'] }.each do |pid|
      item = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid, use_valkyrie: false)
      entity = Sipity::Entity(item)
      next if entity.nil? || entity.workflow_state_name != 'pending_review'

      Hyrax::Workflow::ActivateObject.call(target: item)
      deposited = entity.workflow.workflow_states.find_by(name: 'deposited')
      entity.workflow_state_id = deposited.id
      entity.save!
      item.save
      # Enable once all model objects are fully valkyrized and indexing works again
      # Hyrax.persister.save(resource: item)
      # Hyrax.index_adapter.save(resource: item)
    rescue StandardError => e
      puts "Unable to approve #{pid}"
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end

  desc 'Bulk approve job'
  task bulk_approve_job: :environment do
    collection_id = ENV['collection_id']
    migration_user = Hyrax::Migrator.config.migration_user
    if collection_id.present?
      BulkApproveJob.perform_later(collection_id: collection_id, user: migration_user)
    else
      BulkApproveJob.perform_later(collection_id: nil, user: migration_user)
    end
  end
end
