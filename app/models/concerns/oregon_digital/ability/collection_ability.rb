# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module CollectionAbility
      extend ActiveSupport::Concern

      included do
        def collection_ability
          can(%i[index show new create edit update delete], Hyrax::CollectionType) if current_user.admin?
          can(%i[delete], Collection) if current_user.admin?
          can(%i[index show new create], Collection) if current_user.role?(admin_permission_roles)
          can %i[edit update], Collection do |collection|
            current_user.role?(admin_permission_roles) && in_depositors_collection?(collection.edit_users)
          end
          # TODO: SHOW AND SEARCH FOR UO AND OSU
        end
      end
    end
  end
end
