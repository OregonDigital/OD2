# frozen_string_literal: true

module OregonDigital
  # Collection indexer to extend Hyrax::CollectionIndexer to supper linked data
  class CollectionIndexer < Hyrax::CollectionIndexer
    include OregonDigital::IndexesLinkedMetadata
    include OregonDigital::IndexingDatesBehavior
  end
end
