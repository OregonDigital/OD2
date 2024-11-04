# frozen_string_literal:true

# RSPEC: Create a testing environment to Failed Fetch Mailer class
RSpec.describe OregonDigital::FailedFetchMailer do
  # VARIABLES: Create couple variables for testing purpose
  let(:email) { 'test@email.com' }

  let(:mail) { described_class.with(to: email).failed_fetch_email }

  # TEST GROUP: Create couple test to see if the mailer class pass the test
  it { expect(mail.subject).to eql('Oregon Digital: Failed Fetch Notice') }
  it { expect(mail.to).to eql([email]) }
end
