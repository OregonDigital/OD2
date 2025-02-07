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

    it 'sets all breadcrumbs' do
      expect(controller).to receive(:add_breadcrumb).exactly(3).times
      get :index
    end
  end

  describe '#edit' do
    context 'when I do not have edit permissions for the object' do
      xit 'redirects' do
        get :edit, params: { id: not_my_work }
        expect(response).to render_template(file: File.join(Rails.root, 'public/403.html'))
      end
    end

    context 'when I have permission to edit the object' do
      it 'renders the dashboard' do
        get :edit, params: { id: a_work }
        expect(response).to render_template('dashboard')
      end

      it 'sets all breadcrumbs' do
        expect(controller).to receive(:add_breadcrumb).exactly(4).times
        get :edit, params: { id: a_work }
      end
    end
  end
end
