# frozen_string_literal:true

# Configures the application wide emailer
class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@oregondigital.org'
  layout 'mailer'
end
