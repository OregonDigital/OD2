# frozen_string_literal:true

module OregonDigital
  # Emails users that have reviews to do
  class DeleteUserMailer < ApplicationMailer
    def delete_user
      @user = params[:user]
      mail(to: @user.email, subject: 'Oregon Digital account removal confirmation')
    end
  end
end
