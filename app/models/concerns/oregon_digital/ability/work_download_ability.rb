# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work editing
    module WorkDownloadAbility
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity
        def work_download_ability
          # By default unauthed/community users cannot download full size
          cannot(:download, [ActiveFedora::Base, Hyrax::Resource])
          # You CAN download full quality if you're a UO or OSU authenticated/affiliated user
          can(:download, [ActiveFedora::Base, Hyrax::Resource]) if current_user.role?(self.class.osu_roles + self.class.uo_roles)
          # But you CANNOT download full quality if you cannot show the work (restricted) or it is in UO restricted admin set
          cannot(:download, [ActiveFedora::Base, Hyrax::Resource]) do |record|
            !current_user.can?(:show, record) || uo_download_restricted?(record.try(:admin_set))
          end
          # Can download full quality if overriden by full_size_download_allowed metadata field
          can(:download, [ActiveFedora::Base, Hyrax::Resource]) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'true'
          end
          # Cannot download full quality if overriden by full_size_download_allowed metadata field
          cannot(:download, [ActiveFedora::Base, Hyrax::Resource]) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'false'
          end
          # Can download full quality if admin/manager
          can(:download, [ActiveFedora::Base, Hyrax::Resource]) if current_user.role?(self.class.manager_permission_roles)

          # Can download low/full/metadata if they show it
          can(:download_low, [ActiveFedora::Base, Hyrax::Resource]) do |record|
            current_user.can?(:show, record)
          end
          can(:download_low, [ActiveFedora::Base, Hyrax::Resource]) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'true'
          end
          can(:metadata, [ActiveFedora::Base, Hyrax::Resource]) do |record|
            current_user.can?(:show, record)
          end
          can(%i[download_low metadata], [ActiveFedora::Base, Hyrax::Resource]) do |record|
            OregonDigital::DownloadService.new.all_labels(record.try(:full_size_download_allowed))&.downcase == 'true'
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/CyclomaticComplexity

        def uo_download_restricted?(admin_set)
          admin_sets = YAML.load_file("#{Rails.root}/config/download_restriction.yml")['uo']['admin_sets']
          admin_sets.include?(admin_set.id)
        end
      end
    end
  end
end
