# frozen_string_literal:true

# Provides a catch-all update message
class CollectionUpdateEventJob < CollectionEventJob
  def action
    "User #{link_to_profile depositor} has updated #{link_to collection.title.first, Hyrax::Engine.routes.url_helpers.polymorphic_path(collection)}"
  end
end
