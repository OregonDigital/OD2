# frozen_string_literal: true

module Hyrax
  # OVERRIDE FROM HYRAX
  class ContactFormController < ApplicationController
    include ContactFormRecaptchaBehavior
    before_action :build_contact_form
    layout 'homepage'

    class_attribute :model_class
    self.model_class = OregonDigital::ContactForm

    def new; end

    def create
      # not spam and a valid form
      if @contact_form.valid? && check_recaptcha
        deliver_message
      else
        flash[:error] = 'Sorry, this message was not sent successfully. ' +
                        @contact_form.errors.full_messages.map(&:to_s).join(', ')
      end
      redirect_back fallback_location: '/'
    rescue RuntimeError => e
      handle_create_exception(e)
    end

    def handle_create_exception(exception)
      logger.error("Contact form failed to send: #{exception.inspect}")
      flash[:error] = 'Sorry, this message was not delivered.'
      render :new
    end

    def deliver_message
      ContactMailer.contact(@contact_form).deliver_now
      flash[:notice] = 'Thank you for your message!'
      after_deliver
    end

    # Override this method if you want to perform additional operations
    # when a email is successfully sent, such as sending a confirmation
    # response to the user.
    def after_deliver
      OregonDigital::ContactMailer.contact(@contact_form).deliver_now
    end

    private

    def build_contact_form
      @contact_form = model_class.new(contact_form_params)
    end

    def contact_form_params
      return {} unless params.key?(:oregon_digital_contact_form)

      params.require(:oregon_digital_contact_form).permit(:contact_method, :category, :name, :email, :subject, :message)
    end
  end
end
