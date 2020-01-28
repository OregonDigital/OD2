# frozen_string_literal: true

namespace :migration do
  desc 'update location'
  task update_location: :environment do
    puts 'update location'
    ActiveFedora::SolrService.query('location_tesim:[* TO *]', fl: 'id', rows: 10_000).map { |x| x['id'] }.each do |pid|
      item = ActiveFedora::Base.find(pid)
      new_locations = item.location.map do |loc|
        s = URI(loc.id)
        s.scheme = 'https'
        { 'id' => s.to_s, '_destroy' => 0 }
      end

      if item.location.any? { |loc| loc.id.start_with?('http:') }
        puts "Update location for #{pid}"
        item.location = []
        item.location_attributes = new_locations
        item.save!
      end
    rescue StandardError => e
      puts "Unable to update #{pid}"
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
end
