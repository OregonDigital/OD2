# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work searching
    module WorkSearchAbility
      extend ActiveSupport::Concern

      included do
        def work_search_ability
          # TODO: Fix visibility string for UO and OSU specific visibility settings
          cannot(%i[discover read edit], work_classes + [String])
          can(%i[discover read edit], work_classes + [String]) if current_user.admin?
        end
      end
    end
  end
end
