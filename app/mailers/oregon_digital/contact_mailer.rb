# frozen_string_literal: true

module OregonDigital
  # Mailer for contacting the submitter
  class ContactMailer < ActionMailer::Base
    def contact(contact_form)
      @contact_form = contact_form
      # Check for spam
      return if @contact_form.spam?
      mail(@contact_form.submitter_headers)
    end
  end
end
