# frozen_string_literal: true

# OVERRIDDEN FROM HYRAX TO REMOVE UNUSED FIELDS
require 'linkeddata'
module OregonDigital
  # Used to index linked data
  class DeepIndexingService < Hyrax::DeepIndexingService
    class_attribute :stored_and_facetable_fields, :stored_fields, :symbol_fields
    self.stored_and_facetable_fields = %i[]
    self.stored_fields = %i[]
    self.symbol_fields = %i[]

    protected

    # override Hyrax/ActiveFedora add_assertions to insert combined labels
    # do not index unfetched labels
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def add_assertions(prefix_method, solr_doc = {})
      fetch_external
      fields.each do |field_key, field_info|
        solr_field_key = solr_document_field_name(field_key, prefix_method)
        field_info.values.each do |val|
          next if (val.respond_to? :rdf_label) && (val.rdf_label.first.start_with? 'http')

          append_to_solr_doc(solr_doc, solr_field_key, field_info, val)
          combined_prop = combined_properties[field_key]
          next if combined_prop.blank?

          label = labelize(val)
          append_combined_label(solr_doc, "#{combined_prop}_combined_label", field_info, label)
        end
      end
      solr_doc
    end

    private

    # block this until asset has reached a later stage in its workflow
    # potentially remove block post migration
    def fetch_external
      return if object.ordered_member_ids.blank? && !object.collection?

      object.controlled_properties.each do |property|
        object[property].each do |value|
          resource = value.respond_to?(:resource) ? value.resource : value
          next unless resource.is_a?(ActiveTriples::Resource)

          next if value.is_a?(ActiveFedora::Base)

          # assuming the FetchGraphWorker has run
          # potentially redo using OregonDigital::Triplestore.fetch_cached_term
          fetch_with_persistence(resource)
        end
      end
    end

    # override Hyrax fetch_value to get rid of misleading logging
    def fetch_value(value)
      value.fetch(headers: { 'Accept' => default_accept_header })
    rescue IOError, SocketError, TriplestoreAdapter::TriplestoreException => e
      # IOError could result from a 500 error on the remote server
      # SocketError results if there is no server to connect to
      Rails.logger.error "Unable to fetch #{value.rdf_subject}.\n#{e.message}"
    end

    # modelled after Hyrax::DeepIndexingService methods
    def append_combined_label(solr_doc, solr_field_key, field_info, val)
      ActiveFedora::Indexing::Inserter.create_and_insert_terms(solr_field_key, val, field_info.behaviors, solr_doc)
    end

    # adapted from FetchGraphWorker
    def labelize(val)
      return val if val.first.is_a?(String)

      val.solrize.last.is_a?(String) ? val.solrize.last : val.solrize.last[:label].split('$').first
    end

    def combined_properties
      @combined_properties ||= combined_property_map
    end

    def combined_property_map
      cpm = {}
      %w[ranger_district water_basin location].each do |prop|
        cpm[prop] = 'location'
      end
      %w[arranger artist author cartographer collector composer creator contributor dedicatee donor designer editor illustrator interviewee interviewer lyricist owner patron photographer print_maker recipient transcriber translator].each do |prop|
        cpm[prop] = 'creator'
      end
      %w[keyword subject].each do |prop|
        cpm[prop] = 'topic'
      end
      %w[taxon_class family genus order species phylum_or_division].each do |prop|
        cpm[prop] = 'scientific'
      end
      cpm
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop: enable Metrics/AbcSize
  end
end
