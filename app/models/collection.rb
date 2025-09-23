# frozen_string_literal:true

# Sets the behaviors and other data for a collection
class Collection < ActiveFedora::Base
  after_destroy :destroy_facets
  # temporarily remove fetching until after migration
  # after_save :fetch_graph

  include ::Hyrax::CollectionBehavior
  # You can replace these metadata if they're not suitable
  include OregonDigital::CollectionMetadata
  include OregonDigital::MetadataDownload
  include OregonDigital::AccessControls::Visibility
  self.indexer = OregonDigital::CollectionIndexer

  delegate :facet_configurable?, to: :collection_type

  # Identify facets available to configure
  def available_facets
    generate_default_facets
    facets = Facet.where(collection_id: id)
    facets.sort_by(&:order)
  end

  def insitution_restricted?(current_ability)
    return false if current_ability.can?(:read, self)

    true
  end

  # Adapted from Hyrax::CollectionNesting
  def reindex_extent
    @reindex_extent ||= OD2::Application.config.reindex_extent
  end

  # Borrowed from Hyrax::CollectionNesting
  # rubocop:disable Style/TrivialAccessors
  def reindex_extent=(extent)
    @reindex_extent = extent
  end
  # rubocop:enable Style/TrivialAccessors

  private

  def set_defaults
    self.accessibility_feature = ['unknown']
  end

  # Build new Facet objects that might not exist
  def generate_default_facets
    CatalogController.blacklight_config.facet_fields.each do |_k, facet|
      next unless Facet.where(property_name: facet.field, collection_id: id).empty?

      facet = Facet.new(
        label: facet.label,
        solr_name: facet.field,
        collection_id: id,
        property_name: facet.field
      )
      facet.save
    end
  end

  def destroy_facets
    facets = Facet.where(collection_id: id)
    facets.each(&:destroy)
  end

  def fetch_graph
    FetchGraphWorker.perform_at(2.seconds, id, depositor)
  end
end
