# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchGraphWorker
  include Sidekiq::Worker
  sidekiq_options retry: 11 # Around 2.5 days of retries
  sidekiq_options queue: 'fetch' # Use the 'fetch' queue

  # rubocop:disable Metrics/MethodLength
  # user not needed any longer?
  def perform(pid, _user_key)
    work = ActiveFedora::Base.find(pid)
    work.controlled_properties.each do |controlled_prop|
      work.attributes[controlled_prop.to_s].each do |val|
        next unless val.respond_to?(:fetch)

        val.fetch(headers: { 'Accept' => default_accept_header })
        val.persist!
      rescue TriplestoreAdapter::TriplestoreException, IOError, OregonDigital::ControlledVocabularies::ControlledVocabularyFetchError
        fetch_failed_graph(val)
        next
      end
    end
    work.update_index
  end
  # rubocop:enable Metrics/MethodLength

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
end
