# frozen_string_literal:true

module OregonDigital
  # Emails users that have reviews to do
  class ReviewMailer < ApplicationMailer
    def notification_email
      @user = params[:user]
      @url = 'http://oregondigital.org/notifications'
      mail(to: @user.email, subject: 'Required Reviews in Oregon Digital')
    end
  end
end
