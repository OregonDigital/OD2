# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkShowAbility
      extend ActiveSupport::Concern

      included do
        def work_show_ability
          can :show, ActiveFedora::Base do |record|
            show_record?(record)
          end
          can :read, SolrDocument do |solr_doc|
            read_doc?(solr_doc)
          end

          cannot(%i[show read], FileSet) unless current_user.role?(manager_permission_roles)
          cannot(%i[show read], SolrDocument, visibility: 'osu') unless current_user.role?(osu_roles)
          cannot(%i[show read], SolrDocument, visibility: 'uo') unless current_user.role?(uo_roles)
          cannot(%i[show read], ActiveFedora::Base, visibility: 'uo') unless current_user.role?(uo_roles)
          cannot(%i[show read], ActiveFedora::Base, visibility: 'osu') unless current_user.role?(osu_roles)
        end

        def show_record?(record)
          if record.suppressed?
            current_user.role?(admin_permission_roles) && in_depositors_collection?(record.edit_users)
          else
            current_user.role?(manager_permission_roles)
          end
        end

        def read_doc?(solr_doc)
          if solr_doc.suppressed?
            current_user.role?(admin_permission_roles) && in_depositors_collection?(solr_doc.edit_people)
          else
            current_user.role?(admin_permission_roles)
          end
        end
      end
    end
  end
end
