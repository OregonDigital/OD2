# frozen_string_literal: true

module OregonDigital
  # OVERRIDE FROM HYRAX TO INJECT INDEXING SERVICE
  module IndexesLinkedMetadata
    def rdf_service
      OregonDigital::DeepIndexingService
    end
  end
end
