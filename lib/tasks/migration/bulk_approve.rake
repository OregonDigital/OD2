# frozen_string_literal: true

namespace :migration do
  desc 'Bulk approve migrated items'
  task bulk_approve: :environment do
    puts 'Approving all the things...'
    migration_user = Hyrax::Migrator.config.migration_user
    ActiveFedora::SolrService.query("suppressed_bsi:true AND depositor_ssim:#{migration_user}", fl: 'id', rows: 10_000).map { |x| x['id'] }.each do |pid|
      item = ActiveFedora::Base.find(pid)
      entity = item.to_sipity_entity
      next if entity.nil? || entity.workflow_state_name != 'pending_review'

      Hyrax::Workflow::ActivateObject.call(target: item)
      deposited = entity.workflow.workflow_states.find_by(name: 'deposited')
      entity.workflow_state_id = deposited.id
      entity.save!
      item.save!
    rescue StandardError => e
      puts "Unable to approve #{pid}"
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
end
