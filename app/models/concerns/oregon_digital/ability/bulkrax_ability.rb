# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module BulkraxAbility
      extend ActiveSupport::Concern

      included do
        def can_import_works?
          work_create_ability
        end

        def can_export_works?
          work_create_ability
        end
      end
    end
  end
end
