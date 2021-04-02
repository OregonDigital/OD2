# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module WorkDownloadAbility
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def work_download_ability
          # Can download full res if admin/manager
          can(:download, ActiveFedora::Base) if current_user.role?(manager_permission_roles)
          # Can download OSU/UO and not in a UO restricted admin set
          can(:download, ActiveFedora::Base) do |record|
            current_user.role?(osu_roles + uo_roles) && !uo_download_restricted?(record.admin_set) if record.respond_to?(:admin_set)
          end

          # Cannot download full/low/metadata if they cannot show it
          cannot(:download, ActiveFedora::Base) do |record|
            record.respond_to?(:full_size_download_allowed) && record.full_size_download_allowed
          end
          can(:download_low, ActiveFedora::Base) do |record|
            current_user.can?(:show, record)
          end
          can(:metadata, ActiveFedora::Base) do |record|
            current_user.can?(:show, record)
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def uo_download_restricted?(admin_set)
          admin_sets = YAML.load_file("#{Rails.root}/config/download_restriction.yml")['uo']['admin_sets']
          admin_sets.include?(admin_set.id)
        end
      end
    end
  end
end
