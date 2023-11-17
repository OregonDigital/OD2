# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create admin sets in OregonDigital'
  task create_admin_sets_and_collection_types: :environment do
    puts 'Creating collection types'

    create_initial_collection_types

    user = User.where(email: Hyrax::Migrator.config.migration_user).first
    abort "User with email #{Hyrax::Migrator.config.migration_user} does not exist. An existing migration_user is required for this task." if user.blank?

    puts 'Creating admin sets'

    admin_sets = YAML.load_file("#{Rails.root}/config/initializers/migrator/admin_sets_info.yml")['admin_sets']

    admin_sets.each do |admin_set|
      id = admin_set['id']
      title = admin_set['title']
      description = admin_set['description']
      if AdminSet.exists?(id)
        puts "AdminSet with id \"#{id}\" title \"#{title}\" and description \"#{description}\" already exists."
        next
      end

      admin_set_instance = AdminSet.new(id: id, title: [title], description: [description])
      admin_set_record = Hyrax::AdminSetCreateService.call(admin_set: admin_set_instance, creating_user: user)
      if admin_set_record == true
        puts "Successfully created AdminSet with id \"#{id}\" title \"#{title}\" and description \"#{description}\""
      else
        puts "Unable to create AdminSet with id \"#{id}\" title \"#{title}\" and description \"#{description}\""
      end
    end
  end
end

def create_initial_collection_types
  Hyrax::CollectionType.find_or_create_by(title: 'Digital Collection')
  Hyrax::CollectionType.find_or_create_by(title: 'User Collection')
  Hyrax::CollectionType.find_or_create_by(title: 'OAI Set')
end