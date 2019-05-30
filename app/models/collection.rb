# frozen_string_literal:true

# Sets the behaviors and other data for a collection
class Collection < ActiveFedora::Base
  after_destroy :destroy_facets

  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include Hyrax::BasicMetadata
  self.indexer = Hyrax::CollectionWithBasicMetadataIndexer

  delegate(:facet_configurable?, to: :collection_type)

  def available_facets
    generate_default_facets
    facets = Facet.where(collection_id: id)
    facets.sort_by(&:order)
  end

  private

  def generate_default_facets
    properties_to_facet.each do |_k, prop|
      next unless Facet.where(property_name: prop.term).empty?

      facet = Facet.new(
        label: I18n.translate("simple_form.labels.defaults.#{prop.term}"),
        solr_name: Solrizer.solr_name(prop.term, :facetable),
        collection_id: id,
        property_name: prop.term
      )
      facet.save
    end
  end

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
