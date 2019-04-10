# frozen_string_literal:true

module OregonDigital
  # Emails users that have reviews to do
  class NotificationMailer < ApplicationMailer
    def notification_email
      @user = params[:user]
      @need_keyword = params[:need_keyword]
      @url = 'http://oregondigital.org/notifications'
      mail(to: @user.email, subject: "Required #{ @need_keyword } in Oregon Digital")
    end
  end
end
