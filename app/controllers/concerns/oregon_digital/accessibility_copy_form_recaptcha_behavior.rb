# frozen_string_literal: true

module OregonDigital
  # Behavior for recaptcha
  module AccessibilityCopyFormRecaptchaBehavior
    # METHOD: Check the recaptcha to see if verify or not
    def check_recaptcha
      if recaptcha?
        if verify_recaptcha(model: @accessibility_copy_form)
          true
        else
          flash[:error] = 'Captcha did not verify properly.'
          false
        end
      else
        true
      end
    end

    def recaptcha?
      Hyrax.config.recaptcha?
    end
  end
end
