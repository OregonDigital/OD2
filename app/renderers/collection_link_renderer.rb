# frozen_string_literal:true

# Display config for image object
class CollectionLinkRenderer < Hyrax::Renderers::FacetedAttributeRenderer
  private

  def li_value(value)
    link_to value, Hyrax::Engine.routes.url_helpers.collection_path(value)
  end
end
