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

    def self.issue_types_for_locale
      I18n.t('oregon_digital.contact_form.issue_types').values.select(&:present?)
    end
  end
end
