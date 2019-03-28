# frozen_string_literal:true

RSpec.describe OregonDigital::ContactForm do
  let(:form) { described_class.new(form_data) }
  let(:form_data) { {subject: 'test subject', email: 'test@test.com'} }

  describe '#submitter_headers' do
    context 'with form data' do
      it 'provides email headers' do
        expect(form.submitter_headers).to eq({
          subject: 'Contact form: test subject',
          to: 'test@test.com',
          from: Hyrax.config.contact_email
        })
      end
    end
  end

end
