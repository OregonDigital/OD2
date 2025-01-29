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

    # email users
    notifier.user_map.keys.each do |key|
      message = notifier.build_message(notifier.user_map[key])
      OregonDigital::NotificationMailer.with(email: key, message: message).notification_email.deliver_now
    end

    fetch_notifier.user_map.each do |pid|
      user_email = fetch_notifier.fetch_depositor(pid)
      filename = fetch_notifier.fetch_file(pid)
      OregonDigital::FailedFetchMailer.with(to: user_email, filename: filename.to_s).failed_fetch_email.deliver_now
    end

    metadeities_email = fetch_notifier.fetch_metadeities
    fetch_notifier.create_zip_file
    OregonDigital::FailedFetchMailer.with(to: metadeities_email, filename: 'failed_fetch_items.zip').failed_fetch_email.deliver_now
  end
end
