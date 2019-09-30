# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkReviewAbility
      extend ActiveSupport::Concern

      included do
        def work_review_ability
          can :review, SolrDocument do |solr_doc|
            can_review_solr_doc?(solr_doc.depositor) && can_review_submissions?
          end
        end

        def can_review_solr_doc?(depositor)
          depositor != current_user.email
        end
      end
    end
  end
end
