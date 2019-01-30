# frozen_string_literal: true

# OVERRIDDEN FROM HYRAX TO REMOVE UNUSED FIELDS
require 'linkeddata'
module OregonDigital
  # Used to index linked data
  class DeepIndexingService < Hyrax::DeepIndexingService
    class_attribute :stored_and_facetable_fields, :stored_fields, :symbol_fields
    self.stored_and_facetable_fields = %i[license]
    self.stored_fields = OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.stored_fields -= %i[license]
    self.symbol_fields = %i[]

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
      fetch_value(resource)
      return unless old_label == resource.rdf_subject.to_s || old_label.nil?
      fetch_value(resource)
      return if old_label == resource.rdf_label.first || resource.rdf_label.first == resource.rdf_subject.to_s
      resource.persist! # Stores the fetched values into our marmotta triplestore
    end

    def fetch_value(value)
      Rails.logger.info "Fetching #{value.rdf_subject} from the authorative source. (this is slow)"
      value.fetch(headers: { 'Accept'.freeze => default_accept_header })
    rescue IOError, SocketError => e
      # IOError could result from a 500 error on the remote server
      # SocketError results if there is no server to connect to
      Rails.logger.error "Unable to fetch #{value.rdf_subject} from the authorative source.\n#{e.message}"
    end
  end
end
