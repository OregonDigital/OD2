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

  # Field to use during import to identify if the Work or Collection already exists.
  # Default is 'source'.
  #   config.system_identifier_field = 'source'

  # WorkType to use as the default if none is specified in the import
  # Default is the first returned by Hyrax.config.curation_concerns
  config.default_work_type = 'Image'

  # Path to store pending imports
  config.import_path = '/data/tmp/shared/imports'

  # Path to store exports before download
  config.export_path = '/data/tmp/shared/exports'

  # Path to get the 'file removed' image from
  # config.removed_image_path = '/path/to/removed/image'

  config.parent_child_field_mapping = {
    'Bulkrax::RdfEntry' => 'http://opaquenamespace.org/ns/contents'
  }

  config.collection_field_mapping = {
    'Bulkrax::RdfEntry' => 'http://opaquenamespace.org/ns/set'
  }

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

  config.field_mappings['Bulkrax::BagitComplexParser'] = fieldhash

  # @todo - work with OD to define the config needed here, eg split
  # This needs to be lower case, irrespective of the header row - CSV downcases it
  config.field_mappings['Bulkrax::CsvParser'] = {
    'file' => { from: ['file'], split: true }, # 'ingestfilenametif'
    'identifier' => { from: ['identifier'] },
    'title' => { from: ['title'] },
    'description' => { from: ['description'] },
    'local_collection_name' => { from: ['localcollectionname'], exclude: true },
    'local_collection_id' => { from: ['localcollectionid'] },
    'photographer' => { from: ['photographer'] },
    'date' => { from: ['date'] },
    'subject' => { from: ['lcsubject'], split: /\s*[;|]\s*/ },
    'location' => { from: ['location'] },
    'resource_type' => { from: ['type'] },
    'model' => { from: ['type'], parsed: true },
    'format' => { from: ['format'] },
    'rights_statement' => { from: ['rights'] },
    'rights_holder' => { from: ['rightholder'] },
    'set' => { from: ['set'] },
    'institution' => { from: ['contributinginstitution'] },
    'primary_set' => { from: ['primaryset'] }
  }
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
Bulkrax::CsvEntry.class_eval do
  def required_elements
    # added resource_type, identifier, and rights_statement
    %w[title source_identifier resource_type identifier rights_statement]
  end

  ::Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
end
