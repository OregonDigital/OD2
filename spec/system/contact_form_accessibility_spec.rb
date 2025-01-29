# frozen_string_literal:true

RSpec.describe 'Contact form', js: true, type: :system, clean_repo: true do
  context 'with an annonymous user' do
    xit 'is accessible' do
      visit '/contact'
      expect(page).to be_accessible
    end
  end

  context 'with a logged in user' do
    let(:user) { create(:user) }
    let!(:ability) { ::Ability.new(user) }
    let(:upload_file_path) { "#{Rails.root}/spec/fixtures/test.jpg" }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
      allow(CharacterizeJob).to receive(:perform_later)
      sign_in_as user
    end

    xit 'is accessible' do
      visit '/contact'
      expect(page).to be_accessible
    end
  end
end
