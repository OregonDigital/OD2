module Hyrax
  module Forms
    module Admin
      class CollectionTypeForm
        include ActiveModel::Model
        attr_accessor :collection_type
        validates :title, presence: true

        delegate :title, :description, :brandable, :discoverable, :nestable, :sharable, :facet_configurable, :share_applies_to_new_works,
                 :require_membership, :allow_multiple_membership, :assigns_workflow,
                 :assigns_visibility, :id, :collection_type_participants, :persisted?,
                 :collections?, :admin_set?, :user_collection?, :badge_color, to: :collection_type

        def all_settings_disabled?
          collections? || admin_set? || user_collection?
        end

        def share_options_disabled?
          all_settings_disabled? || !sharable
        end
      end
    end
  end
end