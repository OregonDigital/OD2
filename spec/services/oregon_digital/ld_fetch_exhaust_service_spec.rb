# frozen_string_literal:true

RSpec.describe OregonDigital::LdFetchExhaustService do
  let(:depositor) { create(:user) }
  let(:uri) { 'http://my.queryuri.com' }
  let(:inbox) { depositor.mailbox.inbox }

  describe '#call' do
    subject(:service) { described_class.new(depositor, uri) }

    before do
      service.call
    end

    it { expect(inbox.count).to eq(1) }

    it 'sends error mail with the uri' do
      inbox.each do |msg|
        expect(msg.last_message.body).to include(uri)
      end
    end
  end
end
