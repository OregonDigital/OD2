RSpec.describe OregonDigital::OembedsController do
  let(:user) { create(:user) }
  let(:a_work) { create(:work, user: user) }
  let(:not_my_work) { create(:work) }
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

  describe '#edit' do
    context 'when I do not have edit permissions for the object' do
      it 'redirects' do
        get :edit, params: { id: not_my_work }
        expect(response.status).to eq 302
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end
    context 'when I have permission to edit the object' do
      it 'shows me the page' do
        expect(controller).to receive(:add_breadcrumb).with('Home', subject.root_path)
        expect(controller).to receive(:add_breadcrumb).with('Dashboard', subject.hyrax.dashboard_path)
        expect(controller).to receive(:add_breadcrumb).with('Manage oEmbeds', Rails.application.routes.url_helpers.oembeds_path)
        expect(controller).to receive(:add_breadcrumb).with('Update oEmbed', '#')
        get :edit, params: { id: a_work }
        expect(response).to be_success
        expect(response).to render_template('dashboard')
      end
    end
  end
end
