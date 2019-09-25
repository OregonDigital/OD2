# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create the default OregonDigital roles'
  task create_roles: :environment do
    puts 'Creating roles'
    roles = YAML.load_file("#{Rails.root}/config/roles.yml")['roles']
    roles.each do |name|
      if Role.exists?(name: name)
        puts "Role #{name} already exists."
        next
      end
      role = Role.new(name: name)
      puts "Successfully created role #{name}" if role.save
    rescue StandardError => e
      puts "Unable to create role #{name}"
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
end
