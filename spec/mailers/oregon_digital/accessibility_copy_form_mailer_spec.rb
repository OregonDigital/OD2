# frozen_string_literal:true

# RSPEC: Create a testing environment to Accessibility Copy Form Mailer class
RSpec.describe OregonDigital::AccessibilityCopyFormMailer do
  # VARIABLES: Create couple variables for testing purpose
  let(:accessibility_form) { instance_double('AccessibilityForm') }

  # TEST #1: Look at auto confirmation email
  describe '#auto_contact' do
    context 'when form is not spam' do
      let(:mail_headers) do
        {
          to: 'user@example.com',
          from: 'test@example.com',
          subject: 'Accessibility Copy Request Confirmation'
        }
      end

      before do
        allow(accessibility_form).to receive(:spam?).and_return(false)
        allow(accessibility_form).to receive(:auto_headers).and_return(mail_headers)
        # Stub anything used in the mailer view template
        allow(accessibility_form).to receive(:name).and_return('Test')
        allow(accessibility_form).to receive(:email).and_return('user@example.com')
        allow(accessibility_form).to receive(:description).and_return('test message')
        allow(accessibility_form).to receive(:date).and_return('2025-12-31')
      end

      it 'sends an email with the correct headers' do
        mail = described_class.auto_contact(accessibility_form)
        expect(mail.to).to eq(['user@example.com'])
        expect(mail.from).to eq(['test@example.com'])
        expect(mail.subject).to eq('Accessibility Copy Request Confirmation')
      end
    end

    context 'when form is spam' do
      before do
        allow(accessibility_form).to receive(:spam?).and_return(true)
      end

      it 'does not send any email' do
        expect(described_class.auto_contact(accessibility_form).message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  # TEST #2: Add a test for admin side email
  describe '#admin_contact' do
    context 'when form is not spam' do
      let(:mail_headers) do
        {
          to: 'admin@example.com',
          from: 'test@example.com',
          subject: 'New Accessibility Copy Request'
        }
      end

      before do
        allow(accessibility_form).to receive(:spam?).and_return(false)
        allow(accessibility_form).to receive(:headers).and_return(mail_headers)
        # Stub anything used in the mailer view template
        allow(accessibility_form).to receive(:name).and_return('Test')
        allow(accessibility_form).to receive(:email).and_return('admin@example.com')
        allow(accessibility_form).to receive(:url_link).and_return('www.test.com')
        allow(accessibility_form).to receive(:description).and_return('test message')
        allow(accessibility_form).to receive(:date).and_return('2025-12-31')
      end

      it 'sends an email with the correct headers' do
        mail = described_class.admin_contact(accessibility_form)
        expect(mail.to).to eq(['admin@example.com'])
        expect(mail.from).to eq(['test@example.com'])
        expect(mail.subject).to eq('New Accessibility Copy Request')
      end
    end

    context 'when form is spam' do
      before do
        allow(accessibility_form).to receive(:spam?).and_return(true)
      end

      it 'does not send any email' do
        expect(described_class.admin_contact(accessibility_form).message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
