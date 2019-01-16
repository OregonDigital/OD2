# frozen_string_literal: true

module Hyrax
  # Behavior for recaptcha
  module ContactFormRecaptchaBehavior
    def check_recaptcha
      if recaptcha?
        if verify_recaptcha(model: @contact_form)
          true
        else
          flash.now[:error] = 'Captcha did not verify properly.'
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
