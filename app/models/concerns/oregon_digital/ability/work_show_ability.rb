# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkShowAbility
      extend ActiveSupport::Concern

      included do
        def work_show_ability
          # TODO: Fix visibility string for UO and OSU specific visibility settings
          cannot(%i[show], ActiveFedora::Base, visibility: 'osu') unless current_user.role?(osu_roles)
          cannot(%i[show], ActiveFedora::Base, visibility: 'uo') unless current_user.role?(uo_roles)

          can(%i[show], ActiveFedora::Base) if current_user.role?(manager_permission_roles)
          can(%i[read], SolrDocument) if current_user.role?(admin_permission_roles)
        end
      end
    end
  end
end
