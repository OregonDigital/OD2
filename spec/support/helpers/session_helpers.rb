# frozen_string_literal:true

module Helpers
  module SessionHelpers
    def sign_in_as(who = :user)
      logout(User)
      user = who.is_a?(User) ? who : build(:user).tap(&:save!)
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end
  end
end
