# frozen_string_literal: true

module OregonDigital
  # notify user that export is done
  class ExportMailer < ApplicationMailer
    default from: 'noreply@oregondigital.org'

    def export_ready

      @email = params[:email]
      @subject = params[:subject]
      @url = params[:url]
      Hyrax.logger.info("emailing to #{@email} regarding #{@subject}")
      mail(to: @email, subject: "Export for #{@subject}")
    end
  end
end
