# frozen_string_literal:true

# RSPEC: Create a testing environment to Failed Fetch Mailer class
RSpec.describe OregonDigital::FailedFetchMailer do
  # VARIABLES: Create couple variables for testing purpose
  let(:email) { 'test@email.com' }
  let(:filename) { 'somefile.txt' }
  let(:params) { { to: email, filename: filename } }
  let(:mail) { described_class.with(params).failed_fetch_email }

  # MOCK: Mock the file existence to simulate real file checks
  before do
    allow(File).to receive(:exist?).with("./tmp/failed_fetch/#{filename}").and_return(true)
    allow(File).to receive(:read).with("./tmp/failed_fetch/#{filename}").and_return('file_content')
  end

  # TEST GROUP: Create couple test to see if the mailer class pass the test
  it { expect(mail.subject).to eql('Oregon Digital: Failed Fetch Notice') }
  it { expect(mail.to).to eql([email]) }
  it { expect(mail.attachments[filename].body.to_s).to eq('file_content') }

  it 'does not add any attachments when the file does not exist' do
    # SIMULATE: Simulate the file not existing
    allow(File).to receive(:exist?).with("./tmp/failed_fetch/#{filename}").and_return(false)

    # CHECK: Check that no attachment is added
    expect(mail.attachments).to be_empty
  end
end
