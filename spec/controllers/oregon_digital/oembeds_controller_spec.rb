# frozen_string_literal:true

RSpec.describe OregonDigital::OembedsController do
  let(:user) { create(:user) }
  let(:role) { Role.create(name: 'depositor') }
  let(:a_work) { create(:work, user: user) }
  let(:not_my_work) { create(:work) }

  before do
    user.roles << role
    user.save
    sign_in user
  end

  describe '#index' do
    it 'renders the dashboard' do
      get :index
      expect(response).to render_template('dashboard')
    end

    it "sets up home breadcrumbs" do
      expect(controller).to receive(:add_breadcrumb).with('Home', controller.root_path)
      get :index
    end

    it "sets up dashboard breadcrumbs" do
      expect(controller).to receive(:add_breadcrumb).with('Dashboard', controller.hyrax.dashboard_path)
      get :index
    end 

    it "sets up manage oembeds breadcrumbs" do
      expect(controller).to receive(:add_breadcrumb).with('Manage oEmbeds', Rails.application.routes.url_helpers.oembeds_path)
      get :index
    end
  end

  describe '#edit' do
    context 'when I do not have edit permissions for the object' do
      it 'redirects' do
        get :edit, params: { id: not_my_work }
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    context 'when I have permission to edit the object' do
      it 'renders the dashboard' do
        get :edit, params: { id: a_work }
        expect(response).to render_template('dashboard')
      end

      it "sets up home breadcrumbs" do
        expect(controller).to receive(:add_breadcrumb).with('Home', controller.root_path)
        get :edit, params: { id: a_work }
      end

      it "sets up dashboard breadcrumbs" do
        expect(controller).to receive(:add_breadcrumb).with('Dashboard', controller.hyrax.dashboard_path)
        get :edit, params: { id: a_work }
      end 

      it "sets up manage oembeds breadcrumbs" do
        expect(controller).to receive(:add_breadcrumb).with('Manage oEmbeds', Rails.application.routes.url_helpers.oembeds_path)
        get :edit, params: { id: a_work }
      end

      it "sets up update oembeds breadcrumbs" do
        expect(controller).to receive(:add_breadcrumb).with('Update oEmbed', '#')
        get :edit, params: { id: a_work }
      end
    end
  end
end
