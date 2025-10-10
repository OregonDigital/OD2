# frozen_string_literal: true

module OregonDigital
  # Create a AccessibilityForm for submitting for a copy
  class AccessibilityCopyForm
    include ActiveModel::Model
    # ADD: Add in accessors to map out on field that will be use in the form
    attr_accessor :accessibility_form_method, :name, :email, :url_link, :description, :date

    # VALIDATION: Add in validation to these variables to check before pass the form
    validates :name, :email, :url_link, :description, :date, presence: true
    validates :email, format: /\A([\w.%+-]+)@([\w-]+\.)+(\w{2,})\z/i, allow_blank: true

    # HEADER: Declare the e-mail headers. It accepts anything the mail method in ActionMailer accepts
    def headers
      {
        subject: 'OD2 Accessibility Copy Form: Request',
        to: Hyrax.config.contact_email,
        from: email
      }
    end
  end
end
