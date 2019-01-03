# frozen_string_literal:true

# Sets the behaviors and other data for a collection
class Collection < ActiveFedora::Base
  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include Hyrax::BasicMetadata
  self.indexer = Hyrax::CollectionWithBasicMetadataIndexer
end
