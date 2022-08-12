# frozen_string_literal: true
# Log user profile edits to activity streams
class UserEditProfileEventJob < EventJob
    def perform(user)
      @user = user
      super
    end
      
    def action
      "User profile has been updated by #{@user}"
    end
  end