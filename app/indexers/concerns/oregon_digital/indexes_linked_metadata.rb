module OregonDigital
  # This module can be mixed in on an indexer in order to index the linked metadata fields
  module IndexesLinkedMetadata
    # We're overriding a method from ActiveFedora::IndexingService
    def rdf_service
      OregonDigital::DeepIndexingService
    end
  end
end