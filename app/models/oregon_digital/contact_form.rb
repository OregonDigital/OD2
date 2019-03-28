# frozen_string_literal: true

module OregonDigital
  # Add the submitter as a cc
  class ContactForm < Hyrax::ContactForm
    def headers
      super.merge(cc: email)
    end
  end
end
