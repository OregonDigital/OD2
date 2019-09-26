# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkShowAbility
      extend ActiveSupport::Concern

      included do
        def work_show_ability
          can(%i[show], ActiveFedora::Base)
          # TODO: Configure UO & OSU rules based on how we determine work restriction
          cannot(%i[show], ActiveFedora::Base) if !current_user.role?(osu_roles) && osu_only
          cannot(%i[show], ActiveFedora::Base) if !current_user.role?(uo_roles) && uo_only
        end

        def osu_only
          true
        end

        def uo_only
          true
        end
      end
    end
  end
end
