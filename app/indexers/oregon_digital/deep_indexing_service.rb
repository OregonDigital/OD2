# frozen_string_literal: true

# OVERRIDDEN FROM HYRAX TO REMOVE UNUSED FIELDS
require 'linkeddata'
module OregonDigital
  # Used to index linked data
  class DeepIndexingService < OregonDigital::MetadataIndexer
    def append_to_solr_doc(solr_doc, solr_field_key, field_info, val)
      return super unless object.controlled_properties.include?(solr_field_key.to_sym)
      case val
      when ActiveTriples::Resource
        append_label_and_uri(solr_doc, solr_field_key, field_info, val)
      when String
        append_label(solr_doc, solr_field_key, field_info, val)
      else
        raise ArgumentError, "Can't handle #{val.class}"
      end
    end

    def add_assertions(*)
      fetch_external
      super
    end

    private

    def fetch_external
      object.controlled_properties.each do |property|
        object[property].each do |value|
          resource = value.respond_to?(:resource) ? value.resource : value
          next unless resource.is_a?(ActiveTriples::Resource)
          next if value.is_a?(ActiveFedora::Base)
          fetch_with_persistence(resource)
        end
      end
    end

    def fetch_with_persistence(resource)
      old_label = resource.rdf_label.first
      return unless old_label == resource.rdf_subject.to_s || old_label.nil?
      fetch_value(resource)
      return if old_label == resource.rdf_label.first || resource.rdf_label.first == resource.rdf_subject.to_s
      resource.persist! # Stores the fetched values into our marmotta triplestore
    end

    def fetch_value(value)
      Rails.logger.info "Fetching #{jkvalue.rdf_subject} from the authorative source. (this is slow)"
      value.fetch(headers: { 'Accept' => default_accept_header })
    rescue IOError, SocketError => e
      # IOError could result from a 500 error on the remote server
      # SocketError results if there is no server to connect to
      Rails.logger.error "Unable to fetch #{value.rdf_subject} from the authorative source.\n#{e.message}"
    end

    # Stripping off the */* to work around https://github.com/rails/rails/issues/9940
    def default_accept_header
      RDF::Util::File::HttpAdapter.default_accept_header.sub(%r{/, \*\/\*;q=0\.1\Z/}, '')
    end

    def append_label_and_uri(solr_doc, solr_field_key, field_info, val)
      val = val.solrize
      ActiveFedora::Indexing::Inserter.create_and_insert_terms(solr_field_key,
                                                               val.first,
                                                               field_info.behaviors, solr_doc)
      return unless val.last.is_a? Hash
      ActiveFedora::Indexing::Inserter.create_and_insert_terms("#{solr_field_key}_label",
                                                               label(val),
                                                               field_info.behaviors, solr_doc)
    end

    def append_label(solr_doc, solr_field_key, field_info, val)
      ActiveFedora::Indexing::Inserter.create_and_insert_terms(solr_field_key,
                                                               val,
                                                               field_info.behaviors, solr_doc)
      ActiveFedora::Indexing::Inserter.create_and_insert_terms("#{solr_field_key}_label",
                                                               val,
                                                               field_info.behaviors, solr_doc)
    end

    def label(val)
      val.last[:label].split('$').first
    end
  end
end
