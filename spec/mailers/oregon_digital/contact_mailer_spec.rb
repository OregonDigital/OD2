# frozen_string_literal:true

RSpec.describe OregonDigital::ContactMailer do
  let(:mailer) { described_class.new }
  let(:form) { double }

  describe '#contact' do
    context 'with form data' do
      it 'calls mail()' do
        allow(form).to receive(:spam?).and_return(false)
        allow(form).to receive(:submitter_headers).and_return({})

        expect(mailer).to receive(:mail)
        mailer.contact(form)
      end
    end
  end
end
