module OregonDigital
  class ChangesMailer < ApplicationMailer
    def notification_email
      @user = params[:user]
      @url = "http://oregondigital.org/notifications"
      mail(to: @user.email, subject: 'Required Changes in Oregon Digital')
    end
  end
end
