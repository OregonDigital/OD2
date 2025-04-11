# frozen_string_literal:true

RSpec.describe OregonDigital::NotificationMailer do
  let(:user) { User.new(email: 'jane@email.com') }
  let(:mail) { described_class.with(email: user.email, message: 'plz do thingz').notification_email }

  it { expect(mail.to).to eql([user.email]) }
  it { expect(mail.body).to include('plz do thingz') }
end
