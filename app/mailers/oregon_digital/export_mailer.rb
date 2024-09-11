# frozen_string_literal: true

module OregonDigital
  # notify user that export is done
  class ExportMailer < ApplicationMailer
    default from: 'noreply@oregondigital.org'

    def export_ready
      Hyrax.logger.info("emailing to #{@email} regarding #{@coll_id}")
      @email = params[:email]
      @coll_id = params[:coll_id]
      mail(to: @email, subject: 'Collection members export ready')
    end
  end
end
