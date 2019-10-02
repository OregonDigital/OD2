# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkReviewAbility
      extend ActiveSupport::Concern

      included do
        def work_review_ability
          can :review, SolrDocument do |solr_doc|
            can_review_solr_doc?(solr_doc.depositor) && can_review_submissions? && is_in_depositors_collection?(solr_doc["edit_access_person_ssim"])
          end
        end

        def can_review_solr_doc?(depositor)
          current_user.admin? || depositor != current_user.email
        end
      end
    end
  end
end
