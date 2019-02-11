# frozen_string_literal:true

if Hyrax.config.recaptcha?
  Recaptcha.configure do |config|
    config.site_key  = Hyrax.config.recaptcha_site_key
    config.secret_key = Hyrax.config.recaptcha_secret_key
    # Uncomment the following line if you are using a proxy server:
    # config.proxy = 'http://myproxy.com.au:8080'
  end
end
