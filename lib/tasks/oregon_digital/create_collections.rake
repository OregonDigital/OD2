# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create collections in OregonDigital'
  task create_collections: :environment do
    puts 'Creating collections'
    collections = YAML.load_file("#{Rails.root}/config/initializers/migrator/collections.yml")['collections']
    coll_type_gid = "gid://od2/hyrax-collectiontype/#{prep_collection_type}"
    collections.each do |coll|
      id = coll['id']
      if Collection.exists?(id)
        puts "Collection #{id} already exists."
        next
      end
      title = coll['title']
      visibility = coll['visibility']
      institution = RDF::URI(coll['institution'])
      collection = Collection.new(id: id, title: [title], visibility: visibility, institution: [institution], collection_type_gid: coll_type_gid)
      Hyrax::PermissionTemplate.create!(source_id: id)
      puts "Successfully created collection #{id}" if collection.save
    rescue StandardError => e
      puts "Unable to create collection #{id}"
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
end

def prep_collection_type
  c = Hyrax::CollectionType.where(title: 'Digital Collection').first
  return c.id if c.present?

  c = Hyrax::CollectionType.new(title: 'Digital Collection', facet_configurable: true)
  c.save
  u = User.where(username: 'admin').first
  Hyrax::Collections::PermissionsCreateService.add_access(collection_id: c.id, grants: [{agent_type: Hyrax::PermissionTemplateAccess::USER, agent_id: u.user_key, access: Hyrax::PermissionTemplateAccess::MANAGE }])
  c.id
end
