# frozen_string_literal: true

require 'zip'

namespace :oregon_digital do
  desc 'Send out email if failed fetch is found on Oregon Digital'
  task failed_fetch_notification: :environment do
    # DISPLAY: Create status to show where the process is running
    puts 'Running OregonDigital::FailedFetchNotification'

    # MAILER: Disable mailer so Failed Fetch won't send out email while running check
    ActionMailer::Base.perform_deliveries = false

    # DISPLAY: Display out that we are looping through each filesets
    puts 'Checking if failed_fetch folder exist...'

    # CHECK: If directory exist check for file
    if File.exist?('./tmp/failed_fetch/') || !Dir.empty?('./tmp/failed_fetch/')
      puts 'DIRECTORY FOUND ✓'
      puts 'Now, checking each file and send email ...'
      # LOOP: Loop through the directory to check on file
      Dir.foreach('./tmp/failed_fetch/') do |filename|
        # CHECK: Make sure to check for hidden file
        next if (filename == '.') || (filename == '..')

        # GET: Get the id from the txt file and send email to both user and metadata team
        pid = filename.to_s.gsub('.txt', '')
        work = ActiveFedora::Base.find(pid)

        # MAILER: Enable mailer so it can send out the email now
        ActionMailer::Base.perform_deliveries = true

        # GET: Retrieve user email address
        user_email = work.depositor

        # DELIVER: Delivering the email
        OregonDigital::FailedFetchMailer.with(to: user_email, filename: filename.to_s).failed_fetch_email.deliver_now
      end

      puts 'ALL DEPOSITORS FOUND & HAVE SEND EMAIL ✓'
      puts 'Now zipping all failed fetch to send to metadeities ...'

      create_zip_file
      metadeities_email = 'kevin.jones@oregonstate.edu'
      OregonDigital::FailedFetchMailer.with(to: metadeities_email, filename: 'failed_fetch_items.zip').failed_fetch_email.deliver_now

      puts 'ALL COMPLETE ✓'
    else
      puts 'ALL COMPLETE ✓'
      puts "There's no file found in failed fetch folder or folder does not exist"
    end
  end

  # METHOD: Create a zip file to reduce down the size while sending
  def create_zip_file
    # CHECK: Check if file exist if not create a new one
    File.delete('./tmp/failed_fetch_items.zip') if File.file?('./tmp/failed_fetch_items.zip')
    zip_file = File.new('./tmp/failed_fetch_items.zip', 'w+')

    # ZIP: Add file and zip them together
    Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip|
      # LOOP: Loop through the directory to store in zip
      Dir.foreach('./tmp/failed_fetch/') do |filename|
        # CHECK: Make sure to check for hidden file
        next if (filename == '.') || (filename == '..')

        zip.add(filename.to_s, "./tmp/failed_fetch/#{filename}")
      end
    end
  end
end
