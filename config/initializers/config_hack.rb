Hyrax::Configuration.class_eval do
  attr_writer :recaptcha
  attr_reader :recaptcha
  def recaptcha?
    @recaptcha ||= false
  end

  attr_writer :recaptcha_site_key
  attr_reader :recaptcha_site_key

  attr_writer :recaptcha_secret_key
  attr_reader :recaptcha_secret_key
end