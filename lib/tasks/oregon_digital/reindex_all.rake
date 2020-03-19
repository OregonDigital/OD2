# frozen_string_literal: true
require 'vcr'

namespace :oregon_digital do
  desc 'Create jobs to reindex every asset in Fedora'
  task reindex_all: :environment do
    base_url = ENV.fetch('REINDEX_ALL_FEDORA_URI', ActiveFedora.fedora.base_uri)
    debug = ENV.fetch('REINDEX_ALL_DEBUG', false) == '1'
    record = ENV.fetch('REINDEX_ALL_VCR', false) == '1'

    puts 'Starting reindex...'
    puts '** DEBUG **' if debug

    if record
      puts '*** Recording Fedora API hits with VCR ***'
      puts "    If you're recording in dev, you'll need to change URLs to make the "
      puts "    recording work in test, e.g.:"
      puts
      puts "        sed -i 's|/rest/dev|/rest/test|g' spec/cassettes/fedora-fetch.yml"
      puts "        sed -i 's|fcrepo-dev|fcrepo-test|g' spec/cassettes/fedora-fetch.yml"

      VCR.configure do |c|
        c.hook_into :faraday
        c.cassette_library_dir = 'spec/cassettes'
        c.allow_http_connections_when_no_cassette = true
      end
    end

    # Find *all* objects in Fedora, optionally recording them with VCR
    VCR.insert_cassette('fedora-fetch', :record => :all) if record
    objects = OregonDigital::FedoraFinder.new(base_url).fetch_all
    VCR.eject_cassette if record

    # by_pid organizes objects and metadata by their Fedora pid
    by_pid = {}

    # Various buckets to hold objects that need to have some kind of special
    # processing or have data looked up
    immediates = []
    jobs = []

    # Proxies are weird, and hard to find without just finding all objects in
    # Fedora.  So to make sense of them in terms of when they need indexing, we
    # store which pids have which proxies.
    proxies = Hash.new([])

    # If debug is on, we write out all objects before we even do sanity checks
    objects.each { |obj| obj.write } if debug

    objects.each do |obj|
      # We always key by pid even if the object is purposely ignored
      by_pid[obj.pid] = obj

      case obj.model
      # The "root" object isn't processed in any way
      when 'root'
        puts "skipping root" if debug

      # The collecitons and sets have to be reindexed prior to anything else,
      # and are therefore dubbed "immediates"
      when 'Collection', 'AdminSet'
        puts "adding #{obj.pid} to immediates list (#{obj.model})" if debug
        immediates << obj

      # Assets and file sets are the main reindex targets
      when 'Document', 'Image', 'Audio', 'Generic', 'Video', 'FileSet'
        puts "adding #{obj.pid} to jobs list (#{obj.model})" if debug
        jobs << obj

      # All the access objects should be indexed either by saving the asset
      # or by saving its access controls data - we just list them all here
      # since that ensures we're handling everything
      when 'Hydra::AccessControls::Permission', 'Hydra::AccessControls::Embargo',
           'Hydra::AccessControl'
        puts "skipping #{obj.pid} - access controls are indexed with their asset" if debug

      # Proxy objects need to be indexed after the object for which they are a
      # proxy.  These seem to have multiple meanings, such as relating an
      # object to its fileset(s) or very indiretly relating a collection to its
      # assets.
      when 'ActiveFedora::Aggregation::Proxy'
        puts "adding #{obj.pid} to proxy list for pids #{obj.proxy_for_pids.inspect}" if debug
        obj.proxy_for_pids.each { |pid| proxies[pid] << obj.pid }

      # These objects are still a mystery - it seems like they're always in a
      # "contains" block, so indexing them with their parent is all we need
      when 'ActiveFedora::Aggregation::ListSource',
           'ActiveFedora::IndirectContainer', 'ActiveFedora::DirectContainer'
        puts "skipping #{obj.pid} - lists and containers are indexed with their asset" if debug

      # Anything not handled is either new, and needs an investigation, or was
      # mistakenly missed here
      else
        # Files are known nuisances that we ignore - the REST API returns an
        # error for them, which we hold onto as a null so the code doesn't
        # puke, but we have to handle them here since there's no actual way to
        # know which nulls may be real problems.
        next if obj.raw == nil &&
          obj.parent.model == 'ActiveFedora::DirectContainer' &&
          obj.parent.parent.model == 'FileSet'

        raise "Unknown or unhandled model on object #{obj.pid} (parent #{obj.parent.model}"
      end
    end

    # Iterate over the immediates, index their access controls and then the object itself
    immediates.each do |obj|
      ReindexWorker.new.perform(obj.access_control_pids, obj.pid, obj.contains_pids + proxies[obj.pid])
    end

    # Now just pile on jobs for the assets
    jobs.each do |obj|
      ReindexWorker.perform_async(obj.access_control_pids, obj.pid, obj.contains_pids + proxies[obj.pid])
    end
  end
end
