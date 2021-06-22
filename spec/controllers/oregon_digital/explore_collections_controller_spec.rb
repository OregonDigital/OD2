# frozen_string_literal:true

RSpec.describe OregonDigital::ExploreCollectionsController do
  let(:collection_type) { create(:collection_type, machine_id: :user_collection) }
  let(:collection) { create(:collection, collection_type_gid: "gid://od2/hyrax-collectiontype/#{collection_type.id}") }

  before do
    allow(Hyrax::CollectionType).to receive(:find).with(machine_id: :user_collection).and_return(collection_type)
  end

  describe '#all' do
    subject { get :all, format: 'text/html' }

    it { is_expected.to render_template('index') }
  end

  describe '#osu' do
    subject { get :osu, format: 'text/html' }

    it { is_expected.to render_template('index') }
  end

  describe '#uo' do
    subject { get :uo, format: 'text/html' }

    it { is_expected.to render_template('index') }
  end

  describe '#my' do
    subject { get :my, format: 'text/html' }

    it { is_expected.to render_template('index') }
  end
end
