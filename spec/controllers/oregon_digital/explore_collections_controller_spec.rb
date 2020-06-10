# frozen_string_literal:true

RSpec.describe OregonDigital::ExploreCollectionsController do
  let(:collection_type) { create(:collection_type) }
  let(:collection) { create(:collection, collection_type_gid: "gid://od2/hyrax-collectiontype/#{collection_type.id}") }

  describe '#index' do
    subject { get :index, format: 'text/html' }

    it { is_expected.to render_template('index') }
  end
end
