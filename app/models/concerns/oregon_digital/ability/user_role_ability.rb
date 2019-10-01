# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module UserRoleAbility
      extend ActiveSupport::Concern

      included do
        def user_role_ability
          # admins can do everything
          can(%i[show add_user remove_user index edit update destroy], Role) if current_user.admin?
          # admins cannot do anything with admin role
          cannot(%i[add_user remove_user edit update destroy], Role, name: 'admin')
          # admin collection_curator can see and search users
          can(%i[show index], User) if current_user.role?(admin_permission_roles)
          # admin can edit and delete users
          can(%i[delete edit update], User) if current_user.admin?
          #community_affiliate can edit profile
          can(%i[edit update], user) if current_user.role?(%[community_affiliate])
        end
      end
    end
  end
end
