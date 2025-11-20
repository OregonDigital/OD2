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

  # adding with upgrade to v.8.0.0
  config.object_factory = Bulkrax::ObjectFactory
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
  fieldhash_csv['oembed_urls'] = { from:['oembed_urls'], split: true }
  fieldhash_csv['accessibility_feature'] = { from:['accessibilityFeature'], split: true }
  fieldhash_csv['accessibility_summary'] = { from:['accessibilitySummary'], split: true }
  fieldhash_csv['full_size_download_allowed'][:parsed] = true
  config.field_mappings['Bulkrax::CsvParser'] = fieldhash_csv
end

## override model mapping - map collection to Generic for now
Bulkrax::ApplicationMatcher.class_eval do
  # add full_size_download_allowed to the parsed_fields
  class_attribute :parsed_fields, instance_writer: false, default: ['remote_files', 'language', 'subject', 'types', 'model', 'resource_type', 'format_original', 'full_size_download_allowed']

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
  # override this method from HasMatchers module, included in Entry
  def single_metadata(content)
    content = content.content if content.is_a?(Nokogiri::XML::NodeSet)
    return unless content

    # preempt final line with to_s
    return content if content.is_a? Integer

    Array.wrap(content.to_s.strip).join('; ')
  end

  # override to use add_oembed & add_accessibilities
  def build_metadata
    validate_record

    self.parsed_metadata = {}
    add_identifier
    establish_factory_class
    add_ingested_metadata
    # TODO(alishaevn): remove the collections stuff entirely and only reference collections via the new parents code
    add_collections
    add_visibility
    add_metadata_for_model
    add_rights_statement
    sanitize_controlled_uri_values!
    add_local
    add_oembed

    self.parsed_metadata
  end

  def add_oembed
      self.parsed_metadata['oembed_urls'] = [record['oembed_urls']]
  end

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
      related_parents_parsed_mapping => %i[member_of_collection_ids member_of_work_ids, parent],
      related_children_parsed_mapping => %i[member_collection_ids member_ids]
    }

    relationship_methods.each do |relationship_key, methods|
      next if relationship_key.blank?

      values = []
      methods.each do |m|
        value = hyrax_record.public_send(m) if hyrax_record.respond_to?(m)
        value_id = value.try(:id)&.to_s || value # get the id if it's an object
        values << value_id if value_id.present?
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

Bulkrax::ParserExportRecordSet::Base.class_eval do
  include OregonDigital::ParserExportRecordSetBehavior
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
Bulkrax::Importer.class_eval do
  paginates_per OD2::Application.config.importer_pagination_per
end

Bulkrax::ImportersController.class_eval do
  include OregonDigital::ImporterControllerBehavior
  include OregonDigital::AspaceDigitalObjectExportBehavior

  # change values for default sort
  def importer_table
    @importers = Bulkrax::Importer.order("last_imported_at desc").page(table_page).per(table_per_page)
      @importers = @importers.where(importer_table_search) if importer_table_search.present?
      respond_to do |format|
        format.json { render json: format_importers(@importers) }
      end
    end

  # GET /importers/1/download
  def download
    @importer = Importer.find(params[:importer_id])
    send_file(params[:url])
  end
end

Bulkrax::ExportersController.class_eval do
  # change values for default sort
  def exporter_table
    @exporters = Bulkrax::Exporter.order("created_at desc").page(table_page).per(table_per_page)
    @exporters = @exporters.where(exporter_table_search) if exporter_table_search.present?
    respond_to do |format|
      format.json { render json: format_exporters(@exporters) }
    end
  end
end

Bulkrax::ObjectFactory.class_eval do
  def self.solr_name(field_name)
    if (defined?(Hyrax) && Hyrax.respond_to?(:index_field_mapper))
      Hyrax.index_field_mapper.solr_name(field_name)
    else
      ActiveFedora.index_field_mapper.solr_name(field_name)
    end
  end
end

Bulkrax::ObjectFactoryInterface.class_eval do
  # allow CSVCollectionEntry to handle
  def collection_type(attrs)
    attrs
  end
end

Bulkrax::CsvCollectionEntry.class_eval do
  # only add gid if collection is new; presence will fail a collection update
  # default to Digital Collection: "gid://od2/Hyrax::CollectionType/3"
  def add_collection_type_gid
    return if update?

    return if self.parsed_metadata['collection_type_gid'].present?

    self.parsed_metadata['collection_type_gid'] = Hyrax::CollectionType.find_by(machine_id: 'digital_collection').to_global_id.to_s
  end

  # added for above
  def update?
    return false unless self.parsed_metadata['id'].present?

    Collection.exists? self.parsed_metadata['id']
  end
end

# added in 9.3.1, wait to schedule create_relationship_job
Bulkrax::ScheduleRelationshipsJob.class_eval do
  def perform(importer_id:)
      importer = Bulkrax::Importer.find(importer_id)
      pending_num = importer.entries.left_outer_joins(:latest_status)
                            .where('bulkrax_statuses.status_message IS NULL ').count
      return reschedule(importer_id) unless pending_num.zero?

      wait_time = OD2::Application.config.bulkrax_create_relationships_wait
      importer.last_run.parents.each do |parent_id|
        Bulkrax.relationship_job_class.constantize
                                      .set(wait: wait_time.minutes)
                                      .perform_later(parent_identifier: parent_id,
                                                     importer_run_id: importer.last_run.id)
      end
    end
end

# restore parent_record save from 9.0.2
Bulkrax::CreateRelationshipsJob.class_eval do
  def process_parent_as_work(parent_record:, parent_identifier:)
    conditionally_acquire_lock_for(parent_record.id.to_s) do
      ActiveRecord::Base.uncached do
        Bulkrax::PendingRelationship.where(parent_id: parent_identifier, importer_run_id: @importer_run_id)
                                    .ordered.find_each do |rel|
          raise "#{rel} needs a child to create relationship" if rel.child_id.nil?
          raise "#{rel} needs a parent to create relationship" if rel.parent_id.nil?
          add_to_work(relationship: rel, parent_record: parent_record, ability: ability)
          self.number_of_successes += 1
          @parent_record_members_added = true
        rescue => e
          rel.update(status_message: e.message)
          @number_of_failures += 1
          @errors << e
        end
      end

        # save record if members were added
      if @parent_record_members_added
        Bulkrax.object_factory.save!(resource: parent_record, user: user)
        reloaded_parent = Bulkrax.object_factory.find(parent_record.id)
        Bulkrax.object_factory.update_index(resources: [reloaded_parent])
        Bulkrax.object_factory.publish(event: 'object.membership.updated', object: reloaded_parent, user: @user)
      end
    end
  end

  # one-word tweak: authorize checks for ability to deposit for collection
  def add_to_collection(relationship:, parent_record:, ability:)
    ActiveRecord::Base.uncached do
      _child_entry, child_record = find_record(relationship.child_id, @importer_run_id)
      raise "#{relationship} could not find child record" unless child_record
      raise "Cannot add child collection (ID=#{relationship.child_id}) to parent work (ID=#{relationship.parent_id})" if child_record.collection? && parent_record.work?
      ability.authorize!(:edit, child_record) || check_group(parent_record)
      # We could do this outside of the loop, but that could lead to odd counter failures.
      ability.authorize!(:deposit, parent_record)
      # It is important to lock the child records as they are the ones being saved.
      # However, locking doesn't seem to be working so we will reload the child record before saving.
      # This is a workaround for the fact that the lock manager doesn't seem to be working.
      conditionally_acquire_lock_for(child_record.id.to_s) do
        Bulkrax.object_factory.add_resource_to_collection(
          collection: parent_record,
          resource: child_record,
          user: @user
        )
      end
      relationship.destroy
    end
  end
end

Bulkrax::ApplicationParser.class_eval do

  # parser_fields are set by the importer form
  # do not use a default value at this point
  def visibility
    @visibility ||= self.parser_fields['visibility'] || ''
  end

  ::Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
end
