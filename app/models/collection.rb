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
    facets = Facet.where({collection_id: self.id})
    properties = Document.properties
    properties = properties.merge(Generic.properties)
    properties = properties.merge(Image.properties)
    properties = properties.merge(Video.properties)
    properties.select { |_k, prop| prop.behaviors && prop.behaviors.include?(:facetable) }.each do |_k, prop|
      facet = Facet.new({
        label: I18n.translate("simple_form.labels.defaults.#{prop.term}"),
        solr_name: Solrizer.solr_name(prop.term, :facetable),
        collection_id: self.id,
        property_name: prop.term
      })
      facets += [facet] if facets.select { |f| f.property_name == facet.property_name }.empty? && facet.save
    end
    facets.sort_by { |f| f.order}
  end

  private

    def destroy_facets
      facets = Facet.where({collection_id: self.id})
      facets.each { |f| f.destroy }
    end
end
