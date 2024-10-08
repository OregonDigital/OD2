# frozen_string_literal:true

RSpec.describe OregonDigital::ExploreCollectionsController do
  let(:user) { create(:user) }
  let(:user_collection_type) { create(:collection_type, machine_id: :user_collection) }
  let(:user_collection) { create(:collection, collection_type_gid: "gid://od2/hyrax-collectiontype/#{user_collection_type.id}") }
  let(:oai_collection_type) { create(:collection_type, machine_id: :oai_set) }
  let(:oai_collection) { create(:collection, collection_type_gid: "gid://od2/hyrax-collectiontype/#{oai_collection_type.id}") }

  before do
    allow(Hyrax::CollectionType).to receive(:find).with(machine_id: :user_collection).and_return(user_collection_type)
    allow(Hyrax::CollectionType).to receive(:find).with(machine_id: :oai_set).and_return(oai_collection_type)
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

    before { sign_in user }

    it { is_expected.to render_template('index') }
  end

  describe '#build_breadcrumbs' do
    it 'adds breadcrumbs' do
      expect(controller).to receive(:add_breadcrumb).with('Home',  Hyrax::Engine.routes.url_helpers.root_path(locale: 'en'))
      expect(controller).to receive(:add_breadcrumb).with('Explore Collections / All', 'all')
      get :all
    end
  end
end
