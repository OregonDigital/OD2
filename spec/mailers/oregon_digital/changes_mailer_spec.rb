# frozen_string_literal:true

RSpec.describe OregonDigital::ChangesMailer do
  let(:user) { User.new(email: 'jane@email.com') }
  let(:mail) { described_class.with(user: user).notification_email }

  it { expect(mail.subject).to eql('Required Changes in Oregon Digital') }
  it { expect(mail.to).to eql([user.email]) }
end
