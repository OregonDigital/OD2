# frozen_string_literal: true

module OregonDigital
  # Basically the same thing as Hyrax::ContactForm with headers for the submitter
  class ContactForm < Hyrax::ContactForm
    # Declare the e-mail headers. It accepts anything the mail method
    # in ActionMailer accepts.
    def submitter_headers
      {
        subject: "#{Hyrax.config.subject_prefix} #{subject}",
        to: email,
        from: Hyrax.config.contact_email
      }
    end
  end
end
