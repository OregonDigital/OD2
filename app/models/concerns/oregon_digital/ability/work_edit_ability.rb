# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module WorkEditAbility
      extend ActiveSupport::Concern

      included do
        def work_edit_ability
          # Roles that can edit any work
          can(%i[edit update], work_classes) if current_user.role?(self.class.admin_permission_roles)

          # Roles that can edit their own works
          can(%i[edit update], work_classes, depositor: current_user.email) if current_user.role?(self.class.manager_permission_roles)
        end
      end
    end
  end
end
