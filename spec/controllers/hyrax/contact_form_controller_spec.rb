require 'rails_helper'

RSpec.describe Hyrax::ContactFormController, type: :controller do
  let(:user) {User.new(email: 'test@example.com', guest: false) { |u| u.save!(validate: false)}}
  routes { Hyrax::Engine.routes }
  let(:required_params) do
    {
      category: "Depositing content",
      name: "Rose Tyler",
      email: "rose@timetraveler.org",
      subject: "The Doctor",
      message: "Run."
    }
  end
  let(:contact_form) {Hyrax::ContactForm.new(required_params)}

  before { sign_in(user) }

  describe "#check_recaptcha" do
    before do
      controller.instance_variable_set(:@contact_form, contact_form)
    end
    context "when recaptcha is enabled" do
      let(:params) { required_params }
      before do
        allow(controller).to receive(:is_recaptcha?).and_return(true)
      end
      context "and the recaptcha is not verified" do
        before do
          allow(controller).to receive(:verify_recaptcha).and_return(false)
        end
        it "returns false and throws an error" do
          expect(controller.check_recaptcha).to eq(false)
        end
      end
      context "and the recaptcha is verified" do
        before do
          allow(controller).to receive(:verify_recaptcha).and_return(true)
        end
        it "returns a true value" do
          expect(controller.check_recaptcha).to eq(true)
        end
      end
    end
    context "when recaptcha is not enabled" do
      let(:params) { required_params }
      before do
        allow(controller).to receive(:is_recaptcha?).and_return(false)
      end
      it "returns true and processes the email normally" do
        expect(controller.check_recaptcha).to eq(true)
      end
    end
  end
end
