# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module WorkDownloadAbility
      extend ActiveSupport::Concern

      included do
        def work_download_ability
          can(:download, ActiveFedora::Base) if current_user.role?(manager_permission_roles)
          can(:download_low, ActiveFedora::Base)
        end
      end
    end
  end
end
