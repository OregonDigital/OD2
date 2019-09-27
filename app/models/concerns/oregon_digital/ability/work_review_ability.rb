# frozen_string_literal:true

module OregonDigital
  module Ability
    # Sets the abilities for work displaying
    module WorkReviewAbility
      extend ActiveSupport::Concern

      included do
        def work_review_ability
          Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          Rails.logger.info current_user.email 
          can(%i[review], Depositor) do |depositor|
            #  if (current_user.role?(%w[admin])) || current_user.username == params[:depositor]
            current_user.email == depositor
          end
        end
      end
    end
  end
end

