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
          can :show, ActiveFedora::Base do |record|
            show_record?(record)
          end
          can :read, SolrDocument do |solr_doc|
            read_doc?(solr_doc)
          end

          cannot(%i[show], FileSet) unless current_user.role?(self.class.manager_permission_roles)
          cannot(%i[show], SolrDocument, visibility: 'osu') unless current_user.role?(self.class.osu_roles)
          cannot(%i[show], SolrDocument, visibility: 'uo') unless current_user.role?(self.class.uo_roles)
          cannot(%i[show], ActiveFedora::Base, visibility: 'uo') unless current_user.role?(self.class.uo_roles)
          cannot(%i[show], ActiveFedora::Base, visibility: 'osu') unless current_user.role?(self.class.osu_roles)
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def show_record?(record)
          if record.suppressed?
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
