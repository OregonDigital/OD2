module OD2
  # This module can be mixed in on an indexer in order to index the linked metadata fields
  module IndexesLinkedMetadata
    # We're overriding a method from Hyrax::IndexesLinkedMetadata
    def rdf_service
      OD2::SaDeepIndexingService
    end
  end
end