# frozen_string_literal:true

# Sets the behaviors and other data for a collection
class Collection < ActiveFedora::Base
  after_destroy :destroy_facets

  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include Hyrax::BasicMetadata
  self.indexer = Hyrax::CollectionWithBasicMetadataIndexer

  delegate :facet_configurable?, to: :collection_type

  # Identify facets available to configure
  def available_facets
    generate_default_facets
    facets = Facet.where(collection_id: id)
    facets.sort_by(&:order)
  end

  private

  # Build new Facet objects that might not exist
  def generate_default_facets
    CatalogController.blacklight_config.facet_fields.each do |_k, facet|
      next unless Facet.where(property_name: facet.field, collection_id: id).empty? && facet.if

      facet = Facet.new(
        label: facet.label,
        solr_name: facet.field,
        collection_id: id,
        property_name: facet.field
      )
      facet.save
    end
  end

  # Find properties with :facetable behavior
  def properties_to_facet
    properties = Document.properties
    properties = properties.merge(Generic.properties)
    properties = properties.merge(Image.properties)
    properties = properties.merge(Video.properties)
    properties.select { |_k, prop| prop&.behaviors&.include?(:facetable) }
  end

  def destroy_facets
    facets = Facet.where(collection_id: id)
    facets.each(&:destroy)
  end
end
