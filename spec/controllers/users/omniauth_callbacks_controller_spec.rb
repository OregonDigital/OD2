require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:user) { create(:user) }
  let(:user_object) { User }
  let(:provider) { double("Provider") }

  context "#cas" do
    before do
      allow(user_object).to receive(:from_omniauth).with(anything).and_return(user)
      allow(request).to receive(:env).and_return(request.env.merge({"omniauth.auth" => provider}))
      allow(provider).to receive(:provider).and_return("cas")
    end 
    it "should redirect when authenticated" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      get :cas

      expect(response.status).to eq 302
    end
  end
  context "#saml" do
    before do
      allow(user_object).to receive(:from_omniauth).with(anything).and_return(user)
      allow(request).to receive(:env).and_return(request.env.merge({"omniauth.auth" => provider}))
      allow(provider).to receive(:provider).and_return("cas")
    end 
    it "should redirect when authenticated" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      get :saml

      expect(response.status).to eq 302
    end
  end
end