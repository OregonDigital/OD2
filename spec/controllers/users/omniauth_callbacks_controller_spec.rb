# frozen_string_literal: true

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:user) { create(:user) }
  let(:user_ob) { User }
  let(:provider) { instance_double('Provider') }
  let(:merged_env) { request.env.merge('omniauth.auth' => provider) }
  let(:req) { @request }

  context 'when #cas' do
    before do
      allow(user_ob).to receive(:from_omniauth).with(anything).and_return(user)
      allow(request).to receive(:env).and_return(merged_env)
      allow(provider).to receive(:provider).and_return('cas')
    end

    it 'redirects when authenticated' do
      req.env['devise.mapping'] = Devise.mappings[:user]
      get :cas

      expect(response.status).to eq 302
    end
  end

  context 'when #saml' do
    before do
      allow(user_ob).to receive(:from_omniauth).with(anything).and_return(user)
      allow(request).to receive(:env).and_return(merged_env)
      allow(provider).to receive(:provider).and_return('cas')
    end

    it 'redirects when authenticated' do
      req.env['devise.mapping'] = Devise.mappings[:user]
      get :saml

      expect(response.status).to eq 302
    end
  end
end
