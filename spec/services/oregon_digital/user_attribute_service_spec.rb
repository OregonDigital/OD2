# frozen_string_literal:true

RSpec.describe OregonDigital::UserAttributeService do
  let(:user_params) { { email: email } }
  let(:email) { '' }
  let(:service) { described_class.new(user_params) }
  let(:router) { Rails.application.routes.url_helpers }

  context "when no email exists" do
    it { expect(service.email_redirect_path).to be_nil }
  end
  context "when osu email" do
    let(:email) { 'blah@oregonstate.edu' }
    it { expect(service.email_redirect_path).to eq "#{router.new_osu_session_path}" }
  end
  context "when osu email" do
    let(:email) { 'blah@uoregon.edu' }
    it { expect(service.email_redirect_path).to eq "#{router.new_uo_session_path}" }
  end
end
