module Bulkrax
  class BagitComplexParser < BagitParser

    # Override to map the collection title
    def create_collections
      collections.each do |collection_record|
        # split by ; |
        collection_record.split(/\s*[;|]\s*/).each do |collection|
          metadata = {
            # Override to map the collection title - just this line
            title: lookup_collection(collection),
            Bulkrax.system_identifier_field => [collection],
            visibility: 'open',
            collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.gid
          }
          new_entry = find_or_create_entry(collection_entry_class, collection, 'Bulkrax::Importer', metadata)
          ImportWorkCollectionJob.perform_now(new_entry.id, current_importer_run.id)
        end
      end
    end

    # Override to map the child id
    def create_parent_child_relationships
      parents.each do | key, value |
        parent = entry_class.where(
          identifier: key,
          importerexporter_id: importerexporter.id,
          importerexporter_type: 'Bulkrax::Importer',
        ).first

        # not finding the entries here indicates that the given identifiers are incorrect
        # in that case we should log that
        children = []
        children = value.map do | child |
          # Override to map the child id - just this line
          child = lookup_child(child)
          entry_class.where(
            identifier: child,
            importerexporter_id: importerexporter.id,
            importerexporter_type: 'Bulkrax::Importer',
          ).first
        end.compact.uniq

        if parent.present? && (children.length != value.length)
          # Increment the failures for the number we couldn't find
          # Because all of our entries have been created by now, if we can't find them, the data is wrong
          Rails.logger.error("Expected #{value.length} children for parent entry #{parent.id}, found #{children.length}")
          return if children.length == 0
          Rails.logger.warn("Adding #{children.length} children to parent entry #{parent.id} (expected #{value.length})")
        end
        parent_id = parent.id
        child_entry_ids = children.map { |c| c.id }
        ChildRelationshipsJob.perform_later(parent_id, child_entry_ids, current_importer_run.id)
      end
    end

    # We have an id like this http://oregondigital.org/u?/uo-arch-photos,19138
    #   and we can predictably change it to http://example.org/ns/19138
    def lookup_child(child)
      "http://example.org/ns/#{child.split(',').last}"
    end

    # Use collections.yml to get the collection title
    # If it isn't listed, use the identifier (it's all we have) 
    # Format is http://oregondigital.org/resource/oregondigital:uo-arch-photos
    def lookup_collection(identifier)
      identifier = identifier.split(':').last
      @collections ||= YAML.load(File.read("#{Rails.root}/config/initializers/migrator/collections.yml"))
      title = @collections['collections'].map {|c| c['title'] if c['id'] == identifier }.compact
      if title.blank?
        [identifier]
      else
        title
      end
    end
  end
end
