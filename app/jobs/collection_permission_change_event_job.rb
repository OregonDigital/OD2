# frozen_string_literal:true

# Provides a permission change message for collections
class CollectionPermissionChangeEventJob < CollectionEventJob
  def action
    "User #{link_to_profile depositor} has updated permission of #{link_to collection.title.first, Hyrax::Engine.routes.url_helpers.polymorphic_path(collection)} to #{visibility_badge(collection.visibility)}"
  end
end
