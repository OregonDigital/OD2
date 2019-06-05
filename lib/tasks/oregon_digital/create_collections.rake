# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create collections in OregonDigital'
  task create_collections: :environment do
    puts 'Creating collections'
    collections = YAML.load_file("#{Rails.root}/config/initializers/migrator/collections.yml")['collections']
    coll_type_gid = "gid://od2/hyrax-collectiontype/#{prep_collection_type}"
    collections.each do |coll|
      id = coll['id']
      if collection_exists?(id)
        puts "Collection #{id} already exists."
        next
      end
      title = coll['title']
      visibility = coll['visibility']
      collection = Collection.new(id: id, title: [title], visibility: visibility, collection_type_gid: coll_type_gid)
      puts "Successfully created collection #{id}" if collection.save
    rescue StandardError => e
      puts "Unable to create collection #{id}"
      puts "Error: #{e.message}"
    end
  end
end

def collection_exists?(id)
  c = Collection.where(id: id).first
  c.present?
end

def prep_collection_type
  c = Hyrax::CollectionType.where(title: 'Digital Collection').first
  return c.id if c.present?

  c = Hyrax::CollectionType.new(title: 'Digital Collection')
  c.save
  c.id
end
