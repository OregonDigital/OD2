# frozen_string_literal:true

# Display config for image object
class CollectionLinkRenderer < Hyrax::Renderers::FacetedAttributeRenderer
  private

  def li_value(value)
    collection = Collection.find(value)
    link_to collection.title.first, Hyrax::Engine.routes.url_helpers.collection_path(value)
  end
end
