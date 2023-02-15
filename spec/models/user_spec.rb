# frozen_string_literal: true

RSpec.describe User do
  let(:user) { described_class }
  let(:access_token) { instance_double('AccessToken') }
  let(:extra) { instance_double('Extra') }
  let(:email1) { 'my_primary_email@email.com' }
  let(:email2) { 'myfakeuid@uoregon.edu' }

  describe '#from_omniauth' do
    context 'when given a cas provider' do
      before do
        allow(access_token).to receive(:provider).and_return('cas')
        allow(access_token).to receive(:extra).and_return(extra)
        allow(extra).to receive(:eduPersonPrincipalName).and_return(email1)
        Role.create(name: 'osu_user')
      end

      it 'returns a user with the proper email' do
        expect(user.from_omniauth(access_token).email).to eq email1
      end
    end

    context 'when given a saml provider' do
      before do
        allow(access_token).to receive(:provider).and_return('saml')
        allow(access_token).to receive(:uid).and_return('myfakeuid')
        Role.create(name: 'uo_user')
      end

      it 'returns a user with the proper email' do
        expect(user.from_omniauth(access_token).email).to eq email2
      end
    end

    context 'when given anything else' do
      before do
        allow(access_token).to receive(:provider).and_return('anything else')
        allow(access_token).to receive(:uid).and_return('myfakeuid')
      end

      it 'returns a user with the proper email' do
        expect(user.from_omniauth(access_token).email).to eq 'myfakeuid'
      end
    end
  end
end
