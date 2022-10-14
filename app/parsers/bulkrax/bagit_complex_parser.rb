# frozen_string_literal: true

module Bulkrax
  class BagitComplexParser < BagitParser
    include Bulkrax::HasMatchers
    require 'bagit'

    def factory_class
      Collection
    end

    def mapping
      importerexporter.mapping
    end

    def entry_class
      CsvEntry
    end

    def collection_entry_class
      CsvCollectionEntry
    rescue
      Entry
    end

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
      parents.each do |key, value|
        parent = entry_class.where(
          identifier: key,
          importerexporter_id: importerexporter.id,
          importerexporter_type: 'Bulkrax::Importer'
        ).first

        # not finding the entries here indicates that the given identifiers are incorrect
        # in that case we should log that
        children = []
        children = value.map do |child|
          # Override to map the child id - just this line
          child = lookup_child(child)
          entry_class.where(
            identifier: child,
            importerexporter_id: importerexporter.id,
            importerexporter_type: 'Bulkrax::Importer'
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
      title = @collections['collections'].map { |c| c['title'] if c['id'] == identifier }.compact
      if title.blank?
        [identifier]
      else
        title
      end
    end

    def total
      importerexporter.entries.count
    end

    # Exporter
    def extra_filters
      output = ""
      if importerexporter.start_date.present?
        start_dt = importerexporter.start_date.to_datetime.strftime('%FT%TZ')
        finish_dt = importerexporter.finish_date.present? ? importerexporter.finish_date.to_datetime.end_of_day.strftime('%FT%TZ') : 'NOW'
        output += " AND system_modified_dtsi:[#{start_dt} TO #{finish_dt}]"
      end
      output += importerexporter.work_visibility.present? ? " AND visibility_ssi:#{importerexporter.work_visibility}" : ''
      output += importerexporter.workflow_status.present? ? " AND workflow_state_name_ssim:#{importerexporter.workflow_status}" : ''
      output
    end

    def current_work_ids
      case importerexporter.export_from
      when 'collection'
        ActiveFedora::SolrService.query("member_of_collection_ids_ssim:#{importerexporter.export_source + extra_filters}", rows: 2_000_000_000).map(&:id)
      when 'worktype'
        ActiveFedora::SolrService.query("has_model_ssim:#{importerexporter.export_source + extra_filters}", rows: 2_000_000_000).map(&:id)
      when 'importer'
        importer = Bulkrax::Importer.find(importerexporter.export_source)
        entry_ids = importer.entries.where(type: importer.parser.entry_class.to_s, last_error: [nil, {}, '']).map(&:identifier)
        ActiveFedora::SolrService.query("#{Bulkrax.system_identifier_field}_tesim:(#{entry_ids.join(' OR ')})#{extra_filters}", rows: 2_000_000_000).map(&:id)
      end
    end

    def create_new_entries
      current_work_ids.each_with_index do |wid, index|
        break if limit_reached?(limit, index)

        new_entry = find_or_create_entry(entry_class, wid, 'Bulkrax::Exporter')
        Bulkrax::ExportWorkJob.perform_now(new_entry.id, current_run.id)
      end
    end
    alias create_from_collection create_new_entries
    alias create_from_importer create_new_entries
    alias create_from_worktype create_new_entries

    def write_files
      require 'open-uri'
      require 'socket'
      importerexporter.entries.where(identifier: current_work_ids)[0..limit || total].each do |e|
        bag = BagIt::Bag.new setup_bagit_folder(e.identifier)
        w = ActiveFedora::Base.find(e.identifier)
        w.file_sets.each do |fs|
          file_name = filename(fs)
          next if file_name.blank?

          io = open(fs.original_file.uri)
          file = Tempfile.new([file_name, File.extname(file_name)], binmode: true)
          file.write(io.read)
          file.close
          bag.add_file(file_name, file.path)
        end
        CSV.open(setup_csv_metadata_export_file(e.identifier), 'w', headers: export_headers, write_headers: true) do |csv|
          csv << e.parsed_metadata
        end
        write_triples(e)
        bag.manifest!(algo: 'sha256')
      end
    end

    # Append the file_set id to ensure a unique filename
    def filename(file_set)
      return if file_set.original_file.blank?

      fn = file_set.original_file.file_name.first
      mime = Mime::Type.lookup(file_set.original_file.mime_type)
      ext_mime = MIME::Types.of(file_set.original_file.file_name).first
      if fn.include?(file_set.id)
        return fn if mime.to_s == ext_mime.to_s

        return "#{fn}.#{mime.to_sym}"
      else
        return "#{file_set.id}_#{fn}" if mime.to_s == ext_mime.to_s

        return "#{file_set.id}_#{fn}.#{mime.to_sym}"
      end
    end

    # All possible column names
    def export_headers
      headers = ['id']
      headers << entry_class.source_identifier_field
      headers << 'model'
      importerexporter.mapping.each_key { |key| headers << key unless Bulkrax.reserved_properties.include?(key) && !field_supported?(key) }.sort
      headers << 'file'
      headers
    end

    # in the parser as it is specific to the format
    def setup_csv_metadata_export_file(id)
      File.join(importerexporter.exporter_export_path, id, 'metadata.csv')
    end

    def setup_triple_metadata_export_file(id)
      File.join(importerexporter.exporter_export_path, id, 'metadata.nt')
    end

    def setup_bagit_folder(id)
      File.join(importerexporter.exporter_export_path, id)
    end

    def file_path(entry)
      file_mapping = Bulkrax.field_mappings.dig(self.class.to_s, 'file', :from)&.first&.to_sym || :file
      return [] unless entry[file_mapping].present?

      entry[file_mapping].split(/\s*[:;|]\s*/).map do |f|
        file = File.join(path_to_files, f.tr(' ', '_'))
        if File.exist?(file) # rubocop:disable Style/GuardClause
          file
        else
          raise "File #{file} does not exist"
        end
      end
    end

    def write_triples(e)
      sd = SolrDocument.find(e.identifier)
      return if sd.nil?

      req = ActionDispatch::Request.new({ 'HTTP_HOST' => Socket.gethostname })
      rdf = Hyrax::GraphExporter.new(sd, req).fetch.dump(:ntriples)
      File.open(setup_triple_metadata_export_file(e.identifier), 'w') do |triples|
        triples.write(rdf)
      end
    end
    # errored entries methods

    def write_errored_entries_file
      @errored_entries ||= importerexporter.entries.where.not(last_error: [nil, {}, ''], type: 'Bulkrax::CsvCollectionEntry')
      return unless @errored_entries.present?

      file = setup_errored_entries_file
      headers = import_fields
      file.puts(headers.to_csv)
      @errored_entries.each do |ee|
        row = build_errored_entry_row(headers, ee)
        file.puts(row)
      end
      file.close
      true
    end

    def build_errored_entry_row(headers, errored_entry)
      row = {}
      # Ensure each header has a value, even if it's just an empty string
      headers.each do |h|
        row.merge!("#{h}": nil)
      end
      # Match each value to its corresponding header
      row.merge!(errored_entry.raw_metadata.symbolize_keys)

      row.values.to_csv
    end

    def setup_errored_entries_file
      FileUtils.mkdir_p(File.dirname(importerexporter.errored_entries_csv_path))
      File.open(importerexporter.errored_entries_csv_path, 'w')
    end

    def self.export_supported?
      true
    end
  end
end
