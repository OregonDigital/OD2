# frozen_string_literal: true

module OregonDigital
  # OVERRIDE FROM HYRAX TO INJECT METADATA INDEXER
  module IndexesBasicMetadata
    def rdf_service
      OregonDigital::MetadataIndexer
    end
  end
end
