# frozen_string_literal:true

RSpec.describe OregonDigital::OembedErrorService do
  let(:depositor) { create(:user) }
  let(:inbox) { depositor.mailbox.inbox }
  let(:messages) { ['ERROR ERROR ERROR'] }

  describe '#call' do
    subject(:service) { described_class.new(depositor, messages) }

    before do
      service.call
    end

    it { expect(inbox.count).to eq(1) }

    it 'sends error mail with the proper subject' do
      inbox.each do |msg|
        expect(msg.last_message.subject).to eq('Erroring oEmbed content')
      end
    end

    it 'sends error mail with the proper message' do
      inbox.each do |msg|
        expect(msg.last_message.body).to include(messages.first)
      end
    end
  end
end
