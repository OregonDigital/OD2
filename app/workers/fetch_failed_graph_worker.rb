# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchFailedGraphWorker
  include Sidekiq::Worker
  sidekiq_options retry: 11 # Around 2.5 days of retries
  sidekiq_options queue: 'fetch' # Use the 'fetch' queue

  def perform(val)
    return unless val.respond_to?(:fetch)

    val.fetch(headers: { 'Accept' => default_accept_header })
    val.persist!
  end

  def default_accept_header
    RDF::Util::File::HttpAdapter.default_accept_header.sub(%r{, \*\/\*;q=0\.1\Z}, '')
  end

  def run_success_callback(user, val)
    # val.rdf_subject.value is a string of the URI that was trying to be fetched
    Hyrax.config.callback.run(:ld_fetch_success, user, val.rdf_subject.value)
  end

  sidekiq_retries_exhausted do
    # Email user about exhaustion of retries
    # val.rdf_subject.value is a string of the URI that was trying to be fetched
    Hyrax.config.callback.run(:ld_fetch_exhaust, user, val.rdf_subject.value)
  end
end
