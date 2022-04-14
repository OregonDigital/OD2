# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchGraphWorker
  include Hyrax::Lockable
  include Sidekiq::Worker
  sidekiq_options retry: 11 # Around 2.5 days of retries
  sidekiq_options queue: 'fetch' # Use the 'fetch' queue

  # JOBS TEND TOWARD BEING LARGE. DISABLED BECAUSE FETCHING IS HEAVY HANDED.
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def perform(pid, _user_key)
    acquire_lock_for(pid) do
      # Fetch Work and SolrDoc
      work = ActiveFedora::Base.find(pid)
      solr_doc = SolrDocument.find(pid)
      # TODO: ADD BACK IN WHEN SETTING UP EMAIL
      # user = User.where(email: user_key).first

      # Use 0 for version to tell Solr that the document just needs to exist to be updated
      # Versions dont need to match and set defaults
      solr_doc.response['response']['docs'].first['_version_'] = 0
      solr_doc['_version_'] = 0
      solr_doc['creator_combined_label_sim'] = []
      solr_doc['location_combined_label_sim'] = []
      solr_doc['topic_combined_label_sim'] = solr_doc['keyword_tesim'].to_a
      solr_doc['scientific_combined_label_sim'] = []
      # Iterate over Controller Props values
      work.controlled_properties.each do |controlled_prop|
        # Set to empty array for cleanliness
        solr_doc["#{controlled_prop}_label_sim"] = []
        work.attributes[controlled_prop.to_s].each do |val|
          begin
            # Fetch labels
            if val.respond_to?(:fetch)
              val.fetch(headers: { 'Accept' => default_accept_header })
              val.persist!
            end
          rescue TriplestoreAdapter::TriplestoreException, IOError, OregonDigital::ControlledVocabularies::ControlledVocabularyFetchError
            fetch_failed_graph(pid, val, controlled_prop)
            next
          end

          # Insert into SolrDocument
          val = (val.solrize.last.is_a?(String) ? val.solrize.last : val.solrize.last[:label].split('$').first) unless val.first.is_a?(String)
          solr_doc["#{controlled_prop}_label_sim"] << val
          solr_doc['creator_combined_label_sim'] << val if creator_combined_facet?(controlled_prop)
          solr_doc['location_combined_label_sim'] << val if location_combined_facet?(controlled_prop)
          solr_doc['topic_combined_label_sim'] << val if topic_combined_facet?(controlled_prop)
          solr_doc['scientific_combined_label_sim'] << val if scientific_combined_facet?(controlled_prop)

          solr_doc["#{controlled_prop}_label_tesim"] = solr_doc["#{controlled_prop}_label_sim"]
          solr_doc['creator_combined_label_tesim'] = solr_doc['creator_combined_label_sim']
          solr_doc['location_combined_label_tesim'] = solr_doc['location_combined_label_sim']
          solr_doc['topic_combined_label_tesim'] = solr_doc['topic_combined_label_sim']
          solr_doc['scientific_combined_label_tesim'] = solr_doc['scientific_combined_label_sim']
          Hyrax::SolrService.add(solr_doc)
          Hyrax::SolrService.commit
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # TODO: WILL INTEGRATE THIS WHEN REDOING EMAILING FOR THESE JOBS
  # def fetch_failed_callback(user, val)
  #   Hyrax.config.callback.run(:ld_fetch_failure, user, val.rdf_subject.value)
  # end

  def fetch_failed_graph(pid, val, controlled_prop)
    FetchFailedGraphWorker.perform_async(pid, val, controlled_prop)
  end

  def default_accept_header
    RDF::Util::File::HttpAdapter.default_accept_header.sub(%r{, \*\/\*;q=0\.1\Z}, '')
  end

  def location_combined_facet?(controlled_prop)
    %i[ranger_district water_basin location].include? controlled_prop
  end

  def creator_combined_facet?(controlled_prop)
    %i[arranger artist author cartographer collector composer creator contributor dedicatee donor designer editor illustrator interviewee interviewer lyricist owner patron photographer print_maker recipient transcriber translator].include? controlled_prop
  end

  def topic_combined_facet?(controlled_prop)
    %i[keyword subject].include? controlled_prop
  end

  def scientific_combined_facet?(controlled_prop)
    %i[taxon_class family genus order species phylum_or_division].include? controlled_prop
  end
end
