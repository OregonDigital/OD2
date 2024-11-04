# frozen_string_literal: true

module OregonDigital
  # MAILER: Email user/metadata team for failed fetch cv
  class FailedFetchMailer < ApplicationMailer
    # METHOD: Create an email and send a report to the user
    def failed_fetch_email
      attachments[params[:filename]] = File.read("./tmp/failed_fetch/#{params[:filename]}") if File.exist?("./tmp/failed_fetch/#{params[:filename]}")
      mail(to: params[:to], subject: 'Oregon Digital: Failed Fetch Notice')
    end
  end
end
