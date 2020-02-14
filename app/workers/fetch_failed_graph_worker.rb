# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchFailedGraphWorker
  include Sidekiq::Worker
  sidekiq_options retry: 11 # Around 2.5 days of retries

  # JOBS TEND TOWARD BEING LARGE. DISABLED BECAUSE FETCHING IS HEAVY HANDED.
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def perform(pid, val, controlled_prop)
    # Fetch the work and the solr_doc
    work = ActiveFedora::Base.find(pid)
    solr_doc = SolrDocument.find(pid)

    if val.respond_to?(:fetch)
      val.fetch(headers: { 'Accept' => default_accept_header })
      val.persist!
    end

    # For each behavior
    work.class.index_config[controlled_prop].behaviors.each do |behavior|
      # Insert into SolrDocument
      if val.is_a?(String)
        Solrizer.insert_field(solr_doc, "#{controlled_prop}_label", val, behavior)
      else
        extractred_val = val.solrize.last.is_a?(String) ? val.solrize.last : val.solrize.last[:label].split('$').first
        if controlled_prop == :based_near
          Solrizer.insert_field(solr_doc, 'location_label', [extractred_val], behavior)
        else
          Solrizer.insert_field(solr_doc, "#{controlled_prop}_label", [extractred_val], behavior)
        end
      end
    end

    ActiveFedora::SolrService.add(solr_doc)
    ActiveFedora::SolrService.commit
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

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
