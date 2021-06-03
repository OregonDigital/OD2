# frozen_string_literal: true

module OregonDigital
  # Helpers for displaying OregonDigital's contact form
  module ContactFormHelper
    # OVERRIDE FROM HYRAX: This method override's Hyrax's #contact_form_issue_types_options
    #   in order to redirect to our own ContactForm model
    def contact_form_issue_type_options
      OregonDigital::ContactForm.issue_types_for_locale.dup
    end
  end
end
