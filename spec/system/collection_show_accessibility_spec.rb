# frozen_string_literal:true

RSpec.describe 'Collection show page', js: true, type: :system, clean_repo: true do
  let(:collection_type) { create(:collection_type) }
  let(:collection) { create(:collection, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, collection_type_gid: "gid://od2/hyrax-collectiontype/#{collection_type.id}") }

  before do
    allow_any_instance_of(OregonDigital::CollectionPresenter).to receive(:description).and_return([''])
  end

  context 'with an annonymous user' do
    it 'is accessible' do
      visit "/collections/#{collection.id}"
      expect(page).to be_accessible.excluding('.label-success', '#op')
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
      visit "/collections/#{collection.id}"
      expect(page).to be_accessible.excluding('.label-success', '#op')
    end
  end
end
