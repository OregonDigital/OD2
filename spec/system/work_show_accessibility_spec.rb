# frozen_string_literal:true

RSpec.describe 'Work show page', js: true, type: :system, clean_repo: true do
  let(:work) { create(:work, with_admin_set: true, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, rights_statement: ['http://rightsstatements.org/vocab/InC/1.0/'], creator: ['http://opaquenamespace.org/ns/creator/my_id'], description: ['description']) }

  context 'with an annonymous user' do
    it 'is accessible' do
      visit "/concern/generics/#{work.id}"
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

    it 'is accessible' do
      visit "/concern/generics/#{work.id}"
      expect(page).to be_accessible
    end
  end
end
