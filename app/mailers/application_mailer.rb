# frozen_string_literal:true

# Configures the application wide emailer
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
