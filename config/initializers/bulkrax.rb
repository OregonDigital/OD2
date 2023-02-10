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
  end

  # add model
  fieldhash['model'] = { from: [ 'http://purl.org/dc/terms/type' ], parsed: true }
  # @todo - fix these two
  # add rights; remove license - it will break the view
  fieldhash['rights'] = fieldhash['license']
  fieldhash.delete('license')

  fieldhash['parents'] = { from: ['http://opaquenamespace.org/ns/set'], related_parents_field_mapping: true }
  fieldhash['children'] = { from: ['http://opaquenamespace.org/ns/contents'], related_children_field_mapping: true }
  fieldhash['bulkrax_identifier'] = { from: ['http://id.loc.gov/vocabulary/identifiers/local'], source_identifier: true }
  config.field_mappings['Bulkrax::BagitComplexParser'] = fieldhash

  # Assemble the fields available in the UI form, i.e ORDERED_TERMS
  all_terms = OregonDigital::GenericMetadata::ORDERED_TERMS.union(
    OregonDigital::ImageMetadata::ORDERED_TERMS,
    OregonDigital::DocumentMetadata::ORDERED_TERMS,
    OregonDigital::VideoMetadata::ORDERED_TERMS
  )
  prop_names = all_terms.map{ |x| x[:name].to_s }
  # Need properties for assigning split
  all_props = Generic.properties.clone
  all_props.merge! Document.properties
  all_props.merge! Image.properties
  all_props.merge! Audio.properties
  all_props.merge! Video.properties
  config_hash1 = {}
  prop_names.each do |prop_name|
    prop_hash = { from: [prop_name] }
    prop_hash[:split] = true if all_props[prop_name].multiple?
    config_hash1[prop_name] = prop_hash
  end
  # Fields used by Bulkrax
  config_hash2 = {
    'file' => { from: ['file'], split: true }, # 'ingestfilenametif'
    'model' => { from: ['resource_type'], parsed: true },
    'bulkrax_identifier' => { from: ['original_identifier'], source_identifier: true },
    'parents' => { from: ['parents'], related_parents_field_mapping: true },
    'children' => { from: ['children'], related_children_field_mapping: true }
  }
  config_hash2.merge! config_hash1
  config.field_mappings['Bulkrax::CsvParser'] = config_hash2
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
