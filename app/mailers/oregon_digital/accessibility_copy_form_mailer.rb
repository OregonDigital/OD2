# frozen_string_literal: true

module OregonDigital
  # CLASS: Accessibility Copy Form Mailer for contacting the administrator & depositor request
  class AccessibilityCopyFormMailer < ApplicationMailer
    # METHOD: A method to send an auto confirmation email
    def auto_contact(accessibility_form)
      @accessibility_form = accessibility_form
      # Check for spam
      return if @accessibility_form.spam?

      mail(@accessibility_form.auto_headers)
    end

    # METHOD: A method to send an confirmation email to admin
    def admin_contact(accessibility_form)
      @accessibility_form = accessibility_form
      # Check for spam
      return if @accessibility_form.spam?

      mail(@accessibility_form.headers)
    end
  end
end
