# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkShowAbility
      extend ActiveSupport::Concern

      included do
        def work_show_ability
          # TODO: Configure UO & OSU rules based on how we determine work restriction
          cannot(%i[show], ActiveFedora::Base) if osu_only
          cannot(%i[show], ActiveFedora::Base) if uo_only

          can(%i[show], ActiveFedora::Base) if current_user.role?(manager_permission_roles)
        end

        def osu_only
          !current_user.role?(osu_roles)
        end

        def uo_only
          !current_user.role?(uo_roles)
        end
      end
    end
  end
end
