module OregonDigital
  # This module can be mixed in on an indexer in order to index the basic metadata fields
  module IndexesBasicMetadata
    # We're overriding a method from ActiveFedora::IndexingService
    def rdf_service
      OregonDigital::MetadataIndexer
    end
  end
end