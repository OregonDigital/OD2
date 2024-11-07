# frozen_string_literal: true

module OregonDigital
  # MAILER: Email user/metadata team for failed fetch cv
  class FailedFetchMailer < ApplicationMailer
    # METHOD: Create an email and send a report to the user
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Style/IfInsideElse
    def failed_fetch_email
      if params[:to] == 'kevin.jones@oregonstate.edu'
        attachments[params[:filename]] = File.read("./tmp/#{params[:filename]}") if File.exist?("./tmp/#{params[:filename]}")
      else
        attachments[params[:filename]] = File.read("./tmp/failed_fetch/#{params[:filename]}") if File.exist?("./tmp/failed_fetch/#{params[:filename]}")
      end

      mail(to: params[:to], subject: 'Oregon Digital: Failed Fetch Notice')
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Style/IfInsideElse
  end
end
