# frozen_string_literal: true
require 'vcr'

namespace :oregon_digital do
  desc 'Create jobs to reindex every asset in Fedora'
  task reindex_all: :environment do
    base_url = ENV.fetch('REINDEX_ALL_FEDORA_URI', ActiveFedora.fedora.base_uri)
    debug = ENV.fetch('REINDEX_ALL_DEBUG', false) == '1'
    record = ENV.fetch('REINDEX_ALL_VCR', false) == '1'
    sidekiq_options queue: 'reindex' # Use the 'reindex' queue

    puts 'Starting reindex...'
    puts '** DEBUG **' if debug

    if record
      puts '*** Recording Fedora API hits with VCR ***'
      puts "    If you're recording in dev, you'll need to change URLs to make the "
      puts "    recording work in test, e.g.:"
      puts
      puts "        sed -i 's|http://fcrepo-test:8080/fcrepo/rest/test|<%= fedora_uri %>|g' spec/cassettes/fedora-fetch.yml"

      VCR.configure do |c|
        c.hook_into :faraday
        c.cassette_library_dir = 'spec/cassettes'
        c.allow_http_connections_when_no_cassette = true
      end
    end

    # Find *all* objects in Fedora, optionally recording them with VCR
    finder = OregonDigital::FedoraFinder.new(base_url)
    VCR.insert_cassette('fedora-fetch', :record => :all) if record
    finder.fetch_all
    VCR.eject_cassette if record

    # If debug is on, we write out all objects before we even do sanity checks
    finder.all_objects.each { |obj| obj.write } if debug

    # Iterate over the collections, index their access controls and then the object itself
    finder.collections.each do |obj|
      puts "Immediately running reindex job for collection #{obj.pid}"
      ReindexWorker.new.perform(obj.access_control_pids, obj.pid, obj.contains_pids + obj.proxy_pids)
    end

    # Now just pile on jobs for the assets
    total = finder.assets.length
    finder.assets.each_with_index do |obj, index|
      human_index = index+1
      puts "Creating ReindexWorker job for asset #{human_index} out of #{total}" if human_index % 100 == 0
      ReindexWorker.perform_async(obj.access_control_pids, obj.pid, obj.contains_pids + obj.proxy_pids)
    end

    puts "Reindex task completed - #{total} jobs sent to sidekiq"
  end
end
