# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchGraphWorker
  include Sidekiq::Worker
  sidekiq_options retry: 11 # Around 2.5 days of retries
  sidekiq_options queue: 'fetch' # Use the 'fetch' queue

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # user not needed any longer?
  def perform(pid, _user_key)
    # Create an array to store failed fetch
    failed_cv = []

    # Here be dragons
    # A valkyrie work's controlled properties don't resolve to our OregonDigital::ControlledVocabularies::* objects
    # They resolve to RDF::URI, we need to find a way to get the right CV & index it
    work = ActiveFedora::Base.find(pid)
    work.controlled_properties.each do |controlled_prop|
      work.attributes[controlled_prop.to_s].each do |val|
        next unless val.respond_to?(:fetch)

        val.fetch(headers: { 'Accept' => default_accept_header })
        val.persist!
      rescue TriplestoreAdapter::TriplestoreException, IOError, OregonDigital::ControlledVocabularies::ControlledVocabularyFetchError => e
        failed_cv << { uri: val.to_s, error: e.message }
        fetch_failed_graph(val, pid)
        next
      end
    end
    store_failed_fetch(failed_cv, pid) unless failed_cv.blank?
    work.update_index
  end

  # TODO: WILL INTEGRATE THIS WHEN REDOING EMAILING FOR THESE JOBS
  # def fetch_failed_callback(user, val)
  #   Hyrax.config.callback.run(:ld_fetch_failure, user, val.rdf_subject.value)
  # end

  def fetch_failed_graph(val, _pid)
    FetchFailedGraphWorker.perform_async(val)
  end

  def default_accept_header
    RDF::Util::File::HttpAdapter.default_accept_header.sub(%r{, \*\/\*;q=0\.1\Z}, '')
  end

  # METHOD: Create a method store all fails CV fetch
  def store_failed_fetch(failed_cv, pid)
    # CREATE: Create parent directory and check for exist
    Dir.mkdir './tmp/failed_fetch/' unless File.exist? './tmp/failed_fetch/'

    # PATH: Setup a path for the txt file
    path = "./tmp/failed_fetch/#{pid}.txt"

    # SEARCH: Look for works to create a link
    work = ActiveFedora::Base.find(pid)
    url_path = Rails.application.routes.url_helpers.polymorphic_path(work)
    url_path[0] = ''

    # STORE: Add in data to txt file
    File.open(path, 'w+') do |f|
      f.write("Failed Fetch Record\n")
      f.write("Work ID: #{pid}\n")
      f.write("Work Link: #{[Rails.application.routes.url_helpers.root_url, url_path].join}\n")
      failed_cv.each do |w|
        f.write("Error Placement: #{w[:uri]}   Error on Value: #{w[:error]}\n")
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
