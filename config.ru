# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

# Initialize Honeycomb before everything else
if %w[production staging].include? Rails.env
  require 'honeycomb-beeline'
  Honeycomb.init
end

run Rails.application
