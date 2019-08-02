# frozen_string_literal: true

namespace :uoregon_digital do
  desc 'Bulk approve migrated items'
  task bulk_approve: :environment do
    puts 'Approving all the things...'
    ActiveFedora::SolrService.query('suppressed_bsi:true AND depositor_ssim:admin@example.org', fl: 'id', rows: 10_000).map { |x| x['id'] }.each do |pid|
      item = ActiveFedora::Base.find(pid)
      Hyrax::Workflow::ActivateObject.call(target: item)
      e = item.to_sipity_entity
      e.workflow_state_id = 2
      e.save!
      item.save!
    rescue StandardError => e
      puts "Unable to approve #{pid}"
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
end
