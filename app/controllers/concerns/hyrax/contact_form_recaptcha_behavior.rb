module Hyrax
  module ContactFormRecaptchaBehavior
    def check_recaptcha
      if is_recaptcha?
        if verify_recaptcha(model: @contact_form)
          true
        else
          flash.now[:error] = 'Captcha did not verify properly.'
          flash.now[:error] << @contact_form.errors.full_messages.map(&:to_s).join(", ")
          false
        end
      else
        true
      end
    end

    def is_recaptcha?
      Hyrax.config.recaptcha?
    end
  end
end