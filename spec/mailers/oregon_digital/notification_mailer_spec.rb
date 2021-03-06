# frozen_string_literal:true

RSpec.describe OregonDigital::NotificationMailer do
  let(:user) { User.new(email: 'jane@email.com') }
  let(:mail) { described_class.with(user: user, need_keyword: 'need').notification_email }

  it { expect(mail.subject).to eql('Required need in Oregon Digital') }
  it { expect(mail.to).to eql([user.email]) }
end
