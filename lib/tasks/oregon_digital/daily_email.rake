# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Send out daily email to users based on if changes/review is required'
  task daily_email: :environment do
    notifier = OregonDigital::Notification.new
    # process the items for specific workflows
    notifier.add_review_items
    notifier.add_change_items

    # email users
    notifier.user_map.keys.each do |key|
      message = notifier.build_message(notifier.user_map[key])
      OregonDigital::NotificationMailer.with(email: key, message: message).notification_email.deliver_now
    end
  end
end
