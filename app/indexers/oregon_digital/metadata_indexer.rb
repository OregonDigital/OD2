# frozen_string_literal: true

module OregonDigital
  # OVERRIDE FROM HYRAX TO ADD OUR OWN FIELDS
  class MetadataIndexer < Hyrax::BasicMetadataIndexer
    self.stored_and_facetable_fields = %i[]
    self.stored_fields = %i[]
    self.symbol_fields = %i[]
  end
end
