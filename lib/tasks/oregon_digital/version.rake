# frozen_string_literal: true

require_relative '../../oregon_digital/version'

namespace :oregon_digital do
  desc 'Get the OregonDigital application version'
  task :version do
    puts OregonDigital::VERSION
  end
end
