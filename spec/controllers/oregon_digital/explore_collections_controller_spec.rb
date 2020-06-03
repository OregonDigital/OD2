# frozen_string_literal:true

RSpec.describe OregonDigital::ExploreCollectionsController do
  describe '#index' do
    subject { get :index, format: 'text/html' }

    it { s_expected.to render_template('index') }
  end
end
