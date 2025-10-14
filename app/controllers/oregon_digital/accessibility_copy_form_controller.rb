# frozen_string_literal: true

module OregonDigital
  # CLASS: Accessibility Copy Form Controller
  class AccessibilityCopyFormController < ApplicationController
    # ACTION: Before page load, build the form with all the params
    before_action :build_accessibility_copy_form

    def new; end

    def create
      @accessibility_form = OregonDigital::AccessibilityCopyForm.new(accessibility_copy_form_params)
    end

    # NOTE: Override if needed to perform after email delivery
    def after_deliver; end

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
