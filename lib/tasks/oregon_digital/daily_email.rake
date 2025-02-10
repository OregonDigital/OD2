# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Send out daily email to users based on if changes/review is required'
  task daily_email: :environment do
    notifier = OregonDigital::Notification.new
    # process the items for specific workflows
    notifier.add_review_items
    notifier.add_change_items

    # ADD: Create the Failed Fetch Notification obj
    fetch_notifier = OregonDigital::FailedFetchNotification.new
    fetch_notifier.add_list_of_users

    email users
    notifier.user_map.keys.each do |key|
      message = notifier.build_message(notifier.user_map[key])
      OregonDigital::NotificationMailer.with(email: key, message: message).notification_email.deliver_now
    end

    fetch_notifier.user_map.each do |hash|
      hash.each do |key, value|
        OregonDigital::FailedFetchMailer.with(to: key, filename: value).failed_fetch_email.deliver_now
      end
    end

    fetch_notifier.create_zip_file
    OregonDigital::FailedFetchMailer.with(to: fetch_notifier.fetch_metadeities, filename: 'failed_fetch_items.zip').failed_fetch_email.deliver_now
    fetch_notifier.delete_files unless ActionMailer::Base.deliveries.last.blank?
  end
end
