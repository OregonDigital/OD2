# frozen_string_literal: true
# Log user profile edits to activity streams
class UserEditProfileEventJob < EventJob
    def perform
      super
    end
      
    def action
      "User profile has been updated by #{current_user}"
    end
  end