# frozen_string_literal:true

RSpec.describe 'Authentication pages', js: true, type: :system, clean_repo: true do
  context 'when at the registration page' do
    it 'is accessible' do
      visit '/users/sign_up'
      expect(page).to be_accessible
    end
  end

  context 'when at the sign in page' do
    it 'is accessible' do
      visit '/users/sign_in'
      expect(page).to be_accessible
    end
  end

  context 'when at the password reset page' do
    it 'is accessible' do
      visit '/users/password/new'
      expect(page).to be_accessible
    end
  end
end
