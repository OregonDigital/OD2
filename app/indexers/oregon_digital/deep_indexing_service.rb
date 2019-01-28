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
  end
end
