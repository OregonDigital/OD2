# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module WorkDeleteAbility
      extend ActiveSupport::Concern

      included do
        def work_delete_ability
          can(:delete, ActiveFedora::Base) if current_user.role?(self.class.admin_permission_roles)
        end
      end
    end
  end
end
