# frozen_string_literal: true

module OregonDigital
  # MAILER: Email user/metadata team for failed fetch cv
  class FailedFetchMailer < ApplicationMailer
    # METHOD: Create an email and send a report to the user
    # rubocop:disable Metrics/AbcSize
    def failed_fetch_email
      if params[:to] == 'kevin.jones@oregonstate.edu'
        file_path = "#{Rails.root.join('tmp')}/#{params[:filename]}"
        attachments[params[:filename]] = File.read(file_path) if File.exist?(file_path)
      else
        file_text = "#{Rails.root.join('tmp', 'failed_fetch')}/#{params[:filename]}"
        attachments[params[:filename]] = File.read(file_text) if File.exist?(file_text)
      end

      mail(to: params[:to], subject: 'Oregon Digital: Failed Fetch Notice')
    end
    # rubocop:enable Metrics/AbcSize
  end
end
