# frozen_string_literal:true

module OregonDigital
  # This controller chooses which robots.txt to use based on an env var
  class RobotsController < ApplicationController
    def robots
      robot_type = ENV.fetch('DISABLE_ROBOTS', 'true') == 'true' ? 'staging' : 'production'
      robots = File.read(Rails.root + "config/robots.#{robot_type}.txt")
      render plain: robots, content_type: 'text/plain'
    end
  end
end
