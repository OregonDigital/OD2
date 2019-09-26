# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkShowAbility
      extend ActiveSupport::Concern

      included do
        def work_show_ability
          can(%i[show], ActiveFedora::Base) if current_user.role?(manager_permission_roles)
          # TODO: Configure UO & OSU rules based on how we determine work restriction
          cannot(%i[show], ActiveFedora::Base) if current_user.role?(uo_roles)
          cannot(%i[show], ActiveFedora::Base) if current_user.role?(osu_roles)
          cannot(%i[show], ActiveFedora::Base) if current_user.id.nil?
        end
      end
    end
  end
end
