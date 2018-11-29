RSpec.describe OregonDigital::OembedsController do
  let(:user) { create(:user) }
  before { sign_in user }

  describe '#index' do
    it 'shows me the page' do
      expect(controller).to receive(:add_breadcrumb).with('Home', subject.root_path)
      expect(controller).to receive(:add_breadcrumb).with('Dashboard', subject.hyrax.dashboard_path)
      expect(controller).to receive(:add_breadcrumb).with('Manage oEmbeds', Rails.application.routes.url_helpers.oembeds_path)
      get :index
      expect(response).to be_success
      expect(response).to render_template('dashboard')
    end
  end
end
