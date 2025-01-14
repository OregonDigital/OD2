# frozen_string_literal:true

module OregonDigital
  # Emails users that have reviews to do
  class NotificationMailer < ApplicationMailer
    def notification_email
      @email = params[:email]
      @message = params[:message]
      mail(to: @email, subject: "Required Actions in Oregon Digital")
    end
  end
end
