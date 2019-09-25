# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module WorkEditAbility
      extend ActiveSupport::Concern

      included do
        def work_edit_ability
          # Roles that can edit any work
          can(%i[edit update], work_classes) if current_user.role?(edit_any_work_permissions)

          # Roles that can edit their own works
          can(%i[edit update], work_classes, depositor: current_user.email) if current_user.role?(edit_my_work_permissions)
        end

        def edit_any_work_permissions
          %w[admin collection_curator]
        end

        def edit_my_work_permissions
          %w[admin collection_curator depositor]
        end
      end
    end
  end
end
