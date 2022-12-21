# frozen_string_literal:true

module OregonDigital
  # Emails users that have reviews to do
  class DeleteUserMailer < ApplicationMailer
    def delete_user(user)
      mail(to: user.email, from: Hyrax.config.contact_email, subject: 'Oregon Digital account removal confirmation')
    end
  end
end
