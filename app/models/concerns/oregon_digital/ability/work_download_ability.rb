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
          # Cannot download full quality if they cannot show it or work is in UO restricted admin set
          cannot(:download, ActiveFedora::Base) do |record|
            !current_user.can?(:show, record) || uo_download_restricted?(record.try(:admin_set))
          end
          # Can download full quality if overriden by full_size_download_allowed metadata field
          can(:download, ActiveFedora::Base) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'true'
          end
          # Cannot download full quality if overriden by full_size_download_allowed metadata field
          cannot(:download, ActiveFedora::Base) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'false'
          end
          # Can download full quality if admin/manager
          can(:download, ActiveFedora::Base) if current_user.role?(manager_permission_roles)

          # Can download low/full/metadata if they show it
          can(:download_low, ActiveFedora::Base) do |record|
            current_user.can?(:show, record)
          end
          can(:download_low, ActiveFedora::Base) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'true'
          end
          can(:metadata, ActiveFedora::Base) do |record|
            current_user.can?(:show, record)
          end
          can(%i[download_low metadata], ActiveFedora::Base) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'true'
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
