# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OregonDigital::AccessibilityCopyFormController, type: :controller do
  let(:user) { User.new(email: 'test@example.com', guest: false) { |u| u.save!(validate: false) } }
  let(:required_params) do
    {
      name: 'Test Name',
      email: 'rose@testemail.org',
      url_link: 'www.test.com',
      description: 'test detail',
      date: '2025-12-31'
    }
  end

  let(:accessibility_form) { OregonDigital::AccessibilityCopyForm.new(required_params) }

  routes { Hyrax::Engine.routes }

  before do
    sign_in(user)
  end

  # TEST #1: Check if recaptcha work on the controller
  describe '#check_recaptcha' do
    before do
      controller.instance_variable_set(:@accessibility_form, accessibility_form)
    end

    context 'when recaptcha is enabled' do
      let(:params) { required_params }

      before do
        allow(controller).to receive(:recaptcha?).and_return(true)
      end

      context 'with the recaptcha is not verified' do
        before do
          allow(controller).to receive(:verify_recaptcha).and_return(false)
        end

        it 'returns false and throws an error' do
          expect(controller.check_recaptcha).to eq(false)
        end
      end

      context 'with the recaptcha is verified' do
        before do
          allow(controller).to receive(:verify_recaptcha).and_return(true)
        end

        it 'returns a true value' do
          expect(controller.check_recaptcha).to eq(true)
        end
      end
    end

    context 'when recaptcha is not enabled' do
      let(:params) { required_params }

      before do
        allow(controller).to receive(:recaptcha?).and_return(false)
      end

      it 'returns true and processes the email normally' do
        expect(controller.check_recaptcha).to eq(true)
      end
    end
  end
end
