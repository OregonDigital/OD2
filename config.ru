# This file is used by Rack-based servers to start the application.

# Initialize Honeycomb before everything else
if %w[production staging].include? Rails.env
  require 'honeycomb-beeline'
  Honeycomb.init
end

require_relative 'config/environment'

run Rails.application
