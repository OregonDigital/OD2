# frozen_string_literal: true

RSpec.describe Admin::OregonDigital::CollectionTypesController, type: :controller do
  let(:valid_attributes) do
    {
      title: 'Collection type title',
      description: 'Description of collection type',
      nestable: true,
      discoverable: true,
      sharable: true,
      brandable: true,
      facet_configurable: true,
      share_applies_to_new_works: true,
      allow_multiple_membership: true,
      require_membership: true,
      assigns_workflow: true,
      assigns_visibility: true
    }
  end
  let(:role) { Role.create(name: 'admin') }
  let(:valid_session) { {} }
  let(:collection_type) { create(:collection_type) }
  let(:user) { create(:user) }

  before do
    r = role
    r.users << user
    r.save
    allow(controller.current_ability).to receive(:can?).with(any_args).and_return(true)
    sign_in user
  end

  describe '#create' do
    context 'with valid params' do
      it 'creates a new CollectionType' do
        expect do
          post :create, params: { collection_type: valid_attributes }, session: valid_session
        end.to change(Hyrax::CollectionType, :count).by(1)
      end
    end
  end
end
