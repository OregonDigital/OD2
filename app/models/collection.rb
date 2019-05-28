# frozen_string_literal:true

# Sets the behaviors and other data for a collection
class Collection < ActiveFedora::Base
  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include Hyrax::BasicMetadata
  self.indexer = Hyrax::CollectionWithBasicMetadataIndexer

  delegate(:facet_configurable?, to: :collection_type)

  def available_facets
    Generic.properties.select { |_k, v| v.behaviors && v.behaviors.include?(:facetable) }
  end
end
