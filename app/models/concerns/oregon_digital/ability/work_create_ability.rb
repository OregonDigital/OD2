# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module WorkCreateAbility
      extend ActiveSupport::Concern

      included do
        def work_create_ability
          can(:create, ActiveFedora::Base) if current_user.role?(manager_permission_roles)
        end
      end
    end
  end
end