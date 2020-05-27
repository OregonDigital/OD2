# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module CollectionAbility
      extend ActiveSupport::Concern

      included do
        def collection_ability
          can(%i[index show new create edit update delete], Hyrax::CollectionType) do collection_type
            if collection_type.title == "User Collection"
              true
            else
              current_user.admin?
            end
          end 
          can(%i[create new], Collection) do |collection|
            current_user
          end
          can(%i[delete], Collection) if current_user.admin?
          can(%i[index show], Collection) if current_user.role?(admin_permission_roles)
          can %i[edit update], Collection do |collection|
            admin_or_in_depositor?(collection)
          end
          # TODO: SHOW AND SEARCH FOR UO AND OSU
        end

        def admin_or_in_depositor?(collection)
          current_user.role?(admin_permission_roles) && in_depositors_collection?(collection.edit_users)
        end
      end
    end
  end
end
