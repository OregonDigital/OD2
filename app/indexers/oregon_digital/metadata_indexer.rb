# frozen_string_literal: true

module OregonDigital
  # OVERRIDE FROM HYRAX TO ADD OUR OWN FIELDS
  class MetadataIndexer < Hyrax::BasicMetadataIndexer
    class_attribute :stored_and_facetable_fields, :stored_fields, :symbol_fields
    self.stored_and_facetable_fields = %i[license dcmi_type]
    self.stored_fields = OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.stored_fields -= [:license, :dcmi_type]
    self.symbol_fields = %i[]
    end
  end
end
