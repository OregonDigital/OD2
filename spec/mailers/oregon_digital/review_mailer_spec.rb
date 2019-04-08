# frozen_string_literal:true

RSpec.describe OregonDigital::ReviewMailer do
  let(:user) { mock_model User, name: 'Jane', email: 'jane@email.com' }
  let(:mail) { described_class.with(user: user).notification_email }

  it { expect(mail.subject).to eql('Required Reviews in Oregon Digital') }
  it { expect(mail.to).to eql([user.email]) }
end
