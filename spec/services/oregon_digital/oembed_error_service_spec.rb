RSpec.describe OregonDigital::OembedErrorService do
  let(:depositor) { create(:user) }
  let(:inbox) { depositor.mailbox.inbox }
  let(:message) { ['ERROR ERROR ERROR'] }

  describe '#call' do
    subject { described_class.new(depositor, message) }

    it 'sends error mail' do
      subject.call
      expect(inbox.count).to eq(1)
      inbox.each { |msg| expect(msg.last_message.subject).to eq('Erroring oEmbed content') }
      inbox.each { |msg| expect(msg.last_message.body).to eq("The oEmbed URL attached to a work you deposited has encounted an error: #{message.to_sentence}") }
    end
  end
end
