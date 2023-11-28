# frozen_string_literal: true

module Hyrax
  module Workflow
    # Deletion Approval Notification
    class DeletionApprovalNotification < AbstractNotification
      private

      def subject
        'Requested deletion has been approved'
      end

      def message
        "The deletion request for #{title} (#{link_to work_id, document_path}) was approved by #{user.user_key}. #{comment}"
      end

      def users_to_notify
        user_key = ActiveFedora::Base.find(work_id).depositor
        super << ::User.find_by(email: user_key)
      end
    end
  end
end
