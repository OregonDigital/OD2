# frozen_string_literal: true

module OregonDigital
  # CLASS: Accessibility Copy Form Controller
  class AccessibilityCopyFormController < ApplicationController
    # ACTION: Before page load, build the form with all the params
    before_action :build_accessibility_copy_form

    def new; end

    # rubocop:disable Metrics/AbcSize
    def create
      # SETUP: Build form with all the params and fill in the data once hit on 'send'
      @accessibility_form = OregonDigital::AccessibilityCopyForm.new(accessibility_copy_form_params)

      # CHECK: See if the form is valid
      if @accessibility_form.valid?
        flash[:notice] = t('simple_form.accessibility_copy_form.success')
        after_deliver
      else
        flash[:error] = t('simple_form.accessibility_copy_form.fail')
      end
      # Redirect back to the page the user came from
      redirect_to(params[:return_to].presence || root_path) and return
    rescue RuntimeError => e
      handle_create_exception(e)
    end
    # rubocop:enable Metrics/AbcSize

    # NOTE: Override if needed to perform after email delivery
    def after_deliver; end

    # METHOD: Create a handler for the exception
    def handle_create_exception(exception)
      logger.error("Accessibility Copy Form failed to send: #{exception.inspect}")
      flash[:error] = 'Sorry, this message was not delivered.'
      redirect_to(params[:return_to].presence || root_path) and return
    end

    private

    # METHOD: Create a new form with all the params
    def build_accessibility_copy_form
      @accessibility_form = OregonDigital::AccessibilityCopyForm.new(accessibility_copy_form_params)
    end

    # METHOD: Permits all the required params
    def accessibility_copy_form_params
      return {} unless params.key?(:oregon_digital_accessibility_copy_form)

      params.require(:oregon_digital_accessibility_copy_form).permit(:accessibility_form_method, :name, :email, :url_link, :description, :date)
    end
  end
end
