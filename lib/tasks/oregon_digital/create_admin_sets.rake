# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create admin sets in OregonDigital'
  task create_admin_sets: :environment do
    user = User.where(email: Hyrax::Migrator.config.migration_user).first
    abort "User with email #{Hyrax::Migrator.config.migration_user} does not exist. An existing migration_user is required for this task." if user.blank?

    puts 'Creating admin sets'

    admin_sets = YAML.load_file("#{Rails.root}/config/initializers/migrator/admin_sets_info.yml")['admin_sets']

    admin_sets.each do |admin_set|
      title = admin_set['title']
      description = admin_set['description']
      if admin_set_exists?(title, description) == true
        puts "Admin set with title \"#{title}\" and description \"#{description}\" already exists."
        next
      end

      admin_set_instance = AdminSet.new(title: [title], description: [description])
      admin_set_record = Hyrax::AdminSetCreateService.call(admin_set: admin_set_instance, creating_user: user)
      if admin_set_record == true
        puts "Successfully created AdminSet with title \"#{title}\" and description \"#{description}\""
      else
        puts "Unable to create AdminSet with title \"#{title}\" and description \"#{description}\""
      end
    end
  end
end

def admin_set_exists?(title, description)
  a = AdminSet.where(title: title, description: description).first
  a.present? ? true : false
end
