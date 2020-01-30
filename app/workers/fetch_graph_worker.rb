# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchGraphWorker
  include Sidekiq::Worker
  sidekiq_options retry: 11 # Around 2.5 days of retries

  def perform(pid, user_key)
    # Fetch Work and SolrDoc
    work = ActiveFedora::Base.find(pid)
    solr_doc = SolrDocument.find(pid)
    user = User.where(email: user_key).first

    # Use 0 for version to tell Solr that the document just needs to exist to be updated
    # Versions dont need to match
    solr_doc.response['response']['docs'].first['_version_'] = 0
    solr_doc['_version_'] = 0

    # Iterate over Controller Props values
    work.controlled_properties.each do |controlled_prop|
      work.attributes[controlled_prop.to_s].each do |val|
        # Fetch labels
        if val.respond_to?(:fetch)
          begin
            val.fetch(headers: { 'Accept' => default_accept_header })
          rescue TriplestoreAdapter::TriplestoreException
            fetch_failed_callback(user, val)
            fetch_failed_graph(pid, user, val, controlled_prop)
            next
          end

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
              Solrizer.insert_field(solr_doc, "location_label", [extractred_val], behavior)
            else
              Solrizer.insert_field(solr_doc, "#{controlled_prop}_label", [extractred_val], behavior)
            end
          end
        end
      end
    end

    # Commit Changes
    ActiveFedora::SolrService.add(solr_doc)
    ActiveFedora::SolrService.commit
  end

  def fetch_failed_callback(user, val)
    Hyrax.config.callback.run(:ld_fetch_failure, user, val.rdf_subject.value)
  end

  def fetch_failed_graph(pid, user, val, controlled_prop)
    FetchFailedGraphWorker.perform_async(pid, user, val, controlled_prop)
  end

  def default_accept_header
    RDF::Util::File::HttpAdapter.default_accept_header.sub(%r{, \*\/\*;q=0\.1\Z}, '')
  end
end
