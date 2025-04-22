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
    # Create an array to store failed fetch & call method to check/create exist of tmp folder
    failed_cv = []
    create_and_check_directory

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
        fetch_failed_graph(val)
        next
      end
    end

    # CALL: Invoke the creation of failed_fetch file if array is not empty
    store_failed_fetch(pid, failed_cv) unless failed_cv.blank?
    work.update_index
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # TODO: WILL INTEGRATE THIS WHEN REDOING EMAILING FOR THESE JOBS
  # def fetch_failed_callback(user, val)
  #   Hyrax.config.callback.run(:ld_fetch_failure, user, val.rdf_subject.value)
  # end

  def fetch_failed_graph(val)
    FetchFailedGraphWorker.perform_async(val)
  end

  def default_accept_header
    RDF::Util::File::HttpAdapter.default_accept_header.sub(%r{, \*\/\*;q=0\.1\Z}, '')
  end

  # METHOD: Create a method store all fails CV fetch
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def store_failed_fetch(pid, failed_cv)
    # PATH: Setup a path for the txt file
    path = Rails.root.join('tmp', 'failed_fetch', "#{pid}.txt").to_s

    # SEARCH: Look for works to create a link & get URL path
    work = SolrDocument.find(pid)
    url_path = Rails.application.routes.url_helpers.polymorphic_url(work)

    # STORE: Add in data to txt file
    File.open(path, 'w+') do |f|
      f.puts('Failed Fetch Record')
      f.puts("Work ID: #{pid}")
      f.puts("Work Link: #{url_path}")
      failed_cv.each do |w|
        f.puts("Error Placement: #{w[:uri]}   Error on Value: #{w[:error]}")
      end
      f.puts("Time Recorded: #{Time.now.strftime('%m-%d-%Y %I:%M %p')}")
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # METHOD: Create and check exist of folder
  def create_and_check_directory
    dir_path = Rails.root.join('tmp', 'failed_fetch').to_s
    FileUtils.mkdir_p(dir_path)
  end
end
