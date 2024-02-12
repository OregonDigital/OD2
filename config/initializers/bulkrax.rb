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
    fieldhash[property][:split] = '\|' if c['multiple']
  end

  # add model
  fieldhash['model'] = { from: [ 'http://purl.org/dc/terms/type' ], parsed: true }
  # @todo - fix these two
  # add rights; remove license - it will break the view
  fieldhash['rights'] = fieldhash['license']
  fieldhash.delete('license')
  fieldhash['file'] = { from: ['file'], split: true } # 'ingestfilenametif'
  fieldhash['parents'] = { from: ['parents'], related_parents_field_mapping: true, split: true, join: true}
  fieldhash['children'] = { from: ['children'], related_children_field_mapping: true, split: true }
  fieldhash['bulkrax_identifier'] = { from: ['original_identifier'], source_identifier: true }
  config.field_mappings['Bulkrax::BagitComplexParser'] = fieldhash

  fieldhash_csv = fieldhash.clone
  fieldhash_csv.each do |k,v|
    v['from'] = [k]
  end
  fieldhash_csv['bulkrax_identifier'] = { from: ['original_identifier'], source_identifier: true }
  fieldhash_csv['visibility'] = { from: ['visibility'] }
  config.field_mappings['Bulkrax::CsvParser'] = fieldhash_csv
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

  # commented change to avoid urls in the export headers
  def key_for_export(key)
    clean_key = key_without_numbers(key)
    unnumbered_key = mapping[clean_key] ? mapping[clean_key]['from'].first : clean_key
    # change: revert if it is a uri
    unnumbered_key = clean_key if unnumbered_key.start_with? 'http'
    # Bring the number back if there is one
    "#{unnumbered_key}#{key.sub(clean_key, '')}"
  end

  # check for empty vals: unless data.blank?
  def build_value(key, value)
    return unless hyrax_record.respond_to?(key.to_s)

    data = hyrax_record.send(key.to_s)
    if data.is_a?(ActiveTriples::Relation)
      if value['join']
          self.parsed_metadata[key_for_export(key)] = data.map { |d| prepare_export_data(d) }.join(Bulkrax.multi_value_element_join_on).to_s
      else
        data.each_with_index do |d, i|
          self.parsed_metadata["#{key_for_export(key)}_#{i + 1}"] = prepare_export_data(d)
        end
      end
    else
      self.parsed_metadata[key_for_export(key)] = prepare_export_data(data) unless data.blank?
    end
  end

  # changing call from member_work_ids to member_ids as the former does not return results
  # removing in_work_ids as redundant, member_of_work_ids works for both works and filesets
  # removing file_set_ids as redundant, member_ids returns both child works and filesets
  def build_relationship_metadata
    # Includes all relationship methods for all exportable record types (works, Collections, FileSets)
    relationship_methods = {
      related_parents_parsed_mapping => %i[member_of_collection_ids member_of_work_ids],
      related_children_parsed_mapping => %i[member_collection_ids member_ids]
    }

    relationship_methods.each do |relationship_key, methods|
      next if relationship_key.blank?

      values = []
      methods.each do |m|
        values << hyrax_record.public_send(m) if hyrax_record.respond_to?(m)
      end
      values = values.flatten.uniq
      next if values.blank?

      handle_join_on_export(relationship_key, values, mapping[related_parents_parsed_mapping]['join'].present?)
    end
  end

  # parsed_metadata['visibility'] has already been set by csv values if they exist.
  def add_visibility
    return unless self.parsed_metadata['visibility'].blank?

    # use visibility from importer form if it exists
    self.parsed_metadata['visibility'] = importerexporter.visibility
    return unless self.parsed_metadata['visibility'].blank?

    # set the visibility to default if this is a create
    self.parsed_metadata['visibility'] = 'open' if self.parsed_metadata['id'].blank?
    return unless self.parsed_metadata['visibility'].blank?

    # do not add default visibility to an update
    self.parsed_metadata.delete 'visibility'
  end
end

Bulkrax::CsvParser.class_eval do

  # modify how it uses the export_source value to create file path
  def setup_export_file(folder_count)
    path = File.join(importerexporter.exporter_export_path, folder_count.to_s)
    FileUtils.mkdir_p(path) unless File.exist?(path)
    esource = importerexporter.export_source
    esource = esource.split("/").last.strip if esource.start_with? "http"

    File.join(path, "export_#{esource}_from_#{importerexporter.export_from}_#{folder_count}.csv")
  end

  # switch to batch job if this is a large export
  def create_new_entries
    # divert to new batches method
    return create_new_entries_in_batches if importerexporter.is_large?
      # NOTE: The each method enforces the limit, as it can best optimize the underlying queries.
    current_records_for_export.each do |id, entry_class|
      new_entry = find_or_create_entry(entry_class, id, 'Bulkrax::Exporter')
      begin
        entry = Bulkrax::ExportWorkJob.perform_now(new_entry.id, current_run.id)
      rescue => e
        Rails.logger.info("#{e.message} was detected during export")
      end

    self.headers |= entry.parsed_metadata.keys if entry
    end
  end
  alias create_from_collection create_new_entries
  alias create_from_importer create_new_entries
  alias create_from_worktype create_new_entries
  alias create_from_all create_new_entries
  alias create_from_local_collection create_new_entries

  def create_new_entries_in_batches
    current_records_for_export.in_groups_of(OD2::Application.config.batch_size) do |group|
      OregonDigital::ExportBatchJob.perform_later(group, current_run.id)
    end
  end

  def group_headers(entries)
    headers = []
    entries.each do |entry|
      headers |= entry.parsed_metadata.keys
    end
    self.headers = headers
  end

  # insert call to group_headers
  # generates headers per group of entries if they haven't already been created
  def write_files
    require 'open-uri'
    folder_count = 0
    # TODO: This is not performant as well; unclear how to address, but lower priority as of
    #       <2023-02-21 Tue>.
    sorted_entries = sort_entries(importerexporter.entries.uniq(&:identifier))
                     .select { |e| valid_entry_types.include?(e.type) }
    group_size = limit.to_i.zero? ? total : limit.to_i
    sorted_entries[0..group_size].in_groups_of(records_split_count, false) do |group|
      folder_count += 1
      group_headers(group) if self.headers.empty?
      CSV.open(setup_export_file(folder_count), "w", headers: export_headers, write_headers: true) do |csv|
        group.each do |entry|
          csv << entry.parsed_metadata
          next if importerexporter.metadata_only? || entry.type == 'Bulkrax::CsvCollectionEntry'

          store_files(entry.identifier, folder_count.to_s)
        end
      end
    end
  end
end

Bulkrax::Exporter.class_eval do
  delegate :create_from_local_collection, to: :parser
  def replace_files
    false
  end

  def is_large?
    current_run.total_work_entries > OD2::Application.config.large_export_size
  end

  def export_from_list
      if defined?(::Hyrax)
        [
          [I18n.t('bulkrax.exporter.labels.importer'), 'importer'],
          [I18n.t('bulkrax.exporter.labels.collection'), 'collection'],
          [I18n.t('bulkrax.exporter.labels.worktype'), 'worktype'],
          [I18n.t('bulkrax.exporter.labels.local_collection'), 'local_collection'],
          [I18n.t('bulkrax.exporter.labels.all'), 'all']
        ]
      else
        [
          [I18n.t('bulkrax.exporter.labels.importer'), 'importer'],
          [I18n.t('bulkrax.exporter.labels.collection'), 'collection'],
          [I18n.t('bulkrax.exporter.labels.all'), 'all']
        ]
      end
    end

  def export_source_local_collection
    self.export_source if self.export_from == 'local_collection'
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


  # parser_fields are set by the importer form
  # do not use a default value at this point
  def visibility
    @visibility ||= self.parser_fields['visibility'] || ''
  end

  ::Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
end
