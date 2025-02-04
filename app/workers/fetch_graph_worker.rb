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

    # Check for directory existence and clear out old files if needed
    check_exist_directory

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

    store_failed_fetch(pid) unless failed_cv.blank?
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
  def store_failed_fetch(pid)
    # PATH: Setup a path for the txt file
    path = './tmp/failed_fetch/failed_pid.txt'

    # STORE: Add in pid to txt file
    File.open(path, 'w+') do |f|
      f.write(pid.to_s)
    end
  end

  # METHOD: To clear existing files in directory
  def check_exist_directory
    # CHECK: To see if directory exist
    if File.exist? './tmp/failed_fetch/'
      check_and_clear_exist_files
    else
      Dir.mkdir './tmp/failed_fetch/'
    end
  end

  # METHOD: To clear existing files in directory
  # rubocop:disable Style/GuardClause
  def check_and_clear_exist_files
    # GET: Get the list of files in the folder
    files = Dir.entries('./tmp/failed_fetch') - ['.', '..']

    # CHECK: Check if file not empty
    unless files.empty?
      files.each do |f|
        file_path = File.join('./tmp/failed_fetch', f)
        File.delete(file_path) if File.file?(file_path)
      end
    end
  end
  # rubocop:enable Style/GuardClause
end
