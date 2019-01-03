# frozen_string_literal:true

RSpec.describe OregonDigital::OembedsController do
  let(:user) { create(:user) }
  let(:a_work) { create(:work, user: user) }
  let(:not_my_work) { create(:work) }

  before { sign_in user }

  describe '#index' do
    it { expect(controller).to receive(:add_breadcrumb).with('Home', controller.root_path) }
    it { expect(controller).to receive(:add_breadcrumb).with('Dashboard', controller.hyrax.dashboard_path) }
    it { expect(controller).to receive(:add_breadcrumb).with('Manage oEmbeds', Rails.application.routes.url_helpers.oembeds_path) }
    it 'renders the proper template' do
      get :index
      expect(response).to be_success
    end
  end

  describe '#edit' do
    it 'redirects' do
      get :edit, params: { id: not_my_work }
      expect(response.status).to eq 302
    end
    it { expect(controller).to receive(:add_breadcrumb).with('Home', controller.root_path) }
    it { expect(controller).to receive(:add_breadcrumb).with('Dashboard', controller.hyrax.dashboard_path) }
    it { expect(controller).to receive(:add_breadcrumb).with('Manage oEmbeds', Rails.application.routes.url_helpers.oembeds_path) }
    it { expect(controller).to receive(:add_breadcrumb).with('Update oEmbed', '#') }

    it 'renders the dashboard' do
      get :edit, params: { id: a_work }
      expect(response).to render_template('dashboard')
    end
  end
end
