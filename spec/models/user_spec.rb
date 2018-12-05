require 'rails_helper'

RSpec.describe User do
  let(:user) { User }
  let(:access_token) { double('AccessToken') }
  let(:extra) { double('Extra') }
  describe "#from_omniauth" do
    context "when given a cas provider" do
      before do
        allow(access_token).to receive(:provider).and_return("cas")
        allow(access_token).to receive(:extra).and_return(extra)
        allow(extra).to receive(:osuprimarymail).and_return("my_primary@email.com")
      end
      it 'returns a user with the proper email' do
        expect(user.from_omniauth(access_token).email).to eq "my_primary@email.com"
      end
    end
    context "when given a saml provider" do
      before do
        allow(access_token).to receive(:provider).and_return("saml")
        allow(access_token).to receive(:uid).and_return("myfakeuid")
      end
      it 'returns a user with the proper email' do
        expect(user.from_omniauth(access_token).email).to eq "myfakeuid@uoregon.edu"
      end
    end
    context "when given anything else" do
      before do
        allow(access_token).to receive(:provider).and_return("anything else")
        allow(access_token).to receive(:uid).and_return("myfakeuid")
      end
      it 'returns a user with the proper email' do
        expect(user.from_omniauth(access_token).email).to eq "myfakeuid"
      end
    end
  end
end