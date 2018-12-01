# frozen_string_literal:true

# Initialize Honeycomb before everything else
require 'honeycomb-beeline'
Honeycomb.init

require_relative 'config/environment'
run Rails.application
