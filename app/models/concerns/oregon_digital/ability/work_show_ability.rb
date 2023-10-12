# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkShowAbility
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def work_show_ability
          can :show, [ActiveFedora::Base, Hyrax::Resource] do |record|
            show_record?(record)
          end
          can :read, SolrDocument do |solr_doc|
            read_doc?(solr_doc)
          end

          cannot(%i[show], FileSet) unless current_user.role?(self.class.manager_permission_roles)
          cannot(%i[show], SolrDocument, visibility: 'osu') unless osu_allowed?
          cannot(%i[show], SolrDocument, visibility: 'uo') unless uo_allowed?
          cannot(%i[show], [ActiveFedora::Base, Hyrax::Resource], visibility: 'osu') unless osu_allowed?
          cannot(%i[show], [ActiveFedora::Base, Hyrax::Resource], visibility: 'uo') unless uo_allowed?
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def osu_allowed?
          current_user.role?(self.class.osu_roles) || current_user.role?(self.class.manager_permission_roles)
        end

        def uo_allowed?
          current_user.role?(self.class.uo_roles) || current_user.role?(self.class.manager_permission_roles)
        end

        def show_record?(record)
          if Hyrax::ResourceStatus.new(resource: record).inactive?
            current_user.role?(self.class.admin_permission_roles) && in_depositors_collection?(record.edit_users)
          else
            current_user.role?(self.class.manager_permission_roles)
          end
        end

        def read_doc?(solr_doc)
          if solr_doc.suppressed?
            current_user.role?(self.class.admin_permission_roles) && in_depositors_collection?(solr_doc.edit_people)
          else
            current_user.role?(self.class.admin_permission_roles)
          end
        end
      end
    end
  end
end
