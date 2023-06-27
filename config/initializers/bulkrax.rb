Bulkrax.setup do |config|
  # Add local parsers
  # config.parsers += [
  #   { name: 'MODS - My Local MODS parser', class_name: 'Bulkrax::ModsXmlParser', partial: 'mods_fields' },
  # ]
  config.parsers -= [
    { name: "OAI - Dublin Core", class_name: "Bulkrax::OaiDcParser", partial: "oai_fields" },
    { name: "OAI - Qualified Dublin Core", class_name: "Bulkrax::OaiQualifiedDcParser", partial: "oai_fields" },
    { name: "Bagit", class_name: "Bulkrax::BagitParser", partial: "bagit_fields" }
  ]
  config.parsers += [{ name: "BagIt for Oregon Digital", class_name: "Bulkrax::BagitComplexParser", partial: "bagit_fields" }]

  # WorkType to use as the default if none is specified in the import
  # Default is the first returned by Hyrax.config.curation_concerns
  config.default_work_type = 'Image'

  # Path to store pending imports
  config.import_path = '/data/tmp/shared/imports'

  # Path to store exports before download
  config.export_path = '/data/tmp/shared/exports'

  # Path to get the 'file removed' image from
  # config.removed_image_path = '/path/to/removed/image'

  config.fill_in_blank_source_identifiers = ->(obj, index) { "#{obj.importerexporter.id}-#{index}" }

  # Field mappings
  # Create a completely new set of mappings by replacing the whole set as follows
  #   config.field_mappings = {
  #     "Bulkrax::OaiDcParser" => { **individual field mappings go here*** }
  #   }

  # Add to, or change existing mappings as follows
  #   e.g. to exclude date
  #   config.field_mappings["Bulkrax::OaiDcParser"]["date"] = { from: ["date"], excluded: true  }

  # To duplicate a set of mappings from one parser to another
  #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
  #   config.field_mappings["Bulkrax::OaiDcParser"].each {|key,value| config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value }

  # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
  # config.reserved_properties += ['my_field']

  # Setup the mappings using the Oregon Digital Crosswalk
  crosswalk = YAML.load(File.read("#{Rails.root}/config/initializers/migrator/crosswalk.yml"))
  fieldhash = {}

  # @todo - check the crosswalk is correct

  # TEMPORARY just taking off _attributes
  # @todo - what to do about attributes_data? talk to brandon
  # add the properties
  crosswalk['crosswalk'].each do |c|
    property = c['property']
    next if property.nil?
    property = property.gsub('_attributes', '')
    fieldhash[property] = { from: [] }
  end
  # add the predicates,
  crosswalk['crosswalk'].each do |c|
    property = c['property']
    next if property.nil?
    property = property.gsub('_attributes', '')
    fieldhash[property][:from] << c['predicate']
    fieldhash[property][:split] = '\|' unless c['multiple'].blank?
  end

  # add model
  fieldhash['model'] = { from: [ 'http://purl.org/dc/terms/type' ], parsed: true }
  # @todo - fix these two
  # add rights; remove license - it will break the view
  fieldhash['rights'] = fieldhash['license']
  fieldhash.delete('license')
  fieldhash['file'] = { from: ['file'], split: true } # 'ingestfilenametif'
  fieldhash['parents'] = { from: ['parents'], related_parents_field_mapping: true, split: true}
  fieldhash['children'] = { from: ['children'], related_children_field_mapping: true, split: true }
  fieldhash['bulkrax_identifier'] = { from: ['original_identifier'], source_identifier: true }
  config.field_mappings['Bulkrax::BagitComplexParser'] = fieldhash
  config.field_mappings['Bulkrax::CsvParser'] = fieldhash
end

## override model mapping - map collection to Generic for now
Bulkrax::ApplicationMatcher.class_eval do
  def extract_model(src)
    if src&.match('http://purl.org/dc/dcmitype/Collection')
      'Generic'
    elsif src&.match(URI::ABS_URI)
      src.split('/').last
    else
      src
    end
  rescue StandardError
    nil
  end
end

Bulkrax::CsvEntry.class_eval do
  def key_for_export(key)
    clean_key = key_without_numbers(key)
    unnumbered_key = mapping[clean_key] ? mapping[clean_key]['from'].first : clean_key
    # change: revert if it is a uri
    unnumbered_key = clean_key if unnumbered_key.start_with? 'http'
    # Bring the number back if there is one
    "#{unnumbered_key}#{key.sub(clean_key, '')}"
  end
end

Bulkrax::Exporter.class_eval do
  def replace_files
    false
  end
end
## override CsvEntry#required_elements to include OD-specific required_fields
Bulkrax::ApplicationParser.class_eval do
  def required_elements
    elts = %w[title resource_type identifier rights_statement]
    # added resource_type, identifier, and rights_statement
    elts << source_identifier unless Bulkrax.fill_in_blank_source_identifiers
    elts
  end

  ::Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
end
