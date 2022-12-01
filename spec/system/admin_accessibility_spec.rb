# frozen_string_literal:true

RSpec.describe 'Admin pages', js: true, type: :system, clean_repo: true do
  context 'with a logged in user' do
    let(:user) { create(:user) }
    let(:role) { Role.create(name: 'admin') }
    let!(:ability) { ::Ability.new(user) }
    let(:upload_file_path) { "#{Rails.root}/spec/fixtures/test.jpg" }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
      user.roles << role
      allow(CharacterizeJob).to receive(:perform_later)
      sign_in_as user
    end

    it 'has an accessible dashboard' do
      visit '/dashboard'
      expect(page).to be_accessible
    end

    it 'has an accessible roles dashboard' do
      visit '/roles'
      expect(page).to be_accessible
    end

    it 'has an accessible user dashboard' do
      visit '/users'
      expect(page).to be_accessible
    end
  end
end
