# frozen_string_literal: true

module Hyrax
  module Workflow
    # Tombstone Approval Notification
    class TombstoneApprovalNotification < AbstractNotification
      private

      def subject
        'Requested Tombstone has been approved'
      end

      def message
        "The Tombstone request for #{title} (#{link_to work_id, document_path}) was approved by #{user.user_key}. #{comment}"
      end

      def users_to_notify
        user_key = document.depositor
        super << ::User.find_by(email: user_key)
      end
    end
  end
end
