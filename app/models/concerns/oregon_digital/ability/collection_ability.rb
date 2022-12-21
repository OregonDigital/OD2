# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module CollectionAbility
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def collection_ability
          can(%i[index show new create edit update delete], Hyrax::CollectionType) do |collection_type|
            collection_type.machine_id == 'user_collection' || current_user.admin?
          end
          can(%i[create new], Collection) if current_user
          can(%i[delete], Collection) if current_user.admin?
          can(%i[index show], Collection) if current_user.role?(self.class.admin_permission_roles)
          can %i[edit update], Collection do |collection|
            admin_or_in_depositor?(collection)
          end
          can(%i[download], Collection) do |collection|
            collection.collection_type.machine_id == 'user_collection'
          end
          # TODO: SHOW AND SEARCH FOR UO AND OSU
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def admin_or_in_depositor?(collection)
          current_user.role?(self.class.admin_permission_roles) && in_depositors_collection?(collection.edit_users)
        end
      end
    end
  end
end
