# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Send out daily email to users based on if changes/review is required'
  task daily_email: :environment do
    include OregonDigital::Notification
    # process the items for specific workflows
    add_review_items
    add_change_items

    # email users
    user_map.keys.each do |key|
      message = build_message(user_map[key])
      OregonDigital::NotificationMailer.with(email: key, message: message).deliver_now
    end
  end
end
