# frozen_string_literal: true

module OregonDigital
  # collects, formats, writes assets associated with a given importer as
  # digital objects for import into ArchivesSpace
  class AspaceDigitalObjectExportService
    def initialize(args)
      @importer = Bulkrax::Importer.find(args[:importer_id])
      @email = args[:email]
    end

    def run
      process_entries
      write_file
      ExportMailer.with(email: @email, url: download_url, subject: mail_subject).export_ready.deliver_later
    end

    def process_entries
      identis = @importer.entries.map(&:identifier)
      identis.each do |ident|
        pids = Hyrax::SolrService.query("bulkrax_identifier_sim:#{ident}", fl: 'id', rows: 1).map { |x| x['id'] }
        if pids.empty?
          errors << "No work for #{ident}"
          next
        end
        ado = build(pids.first)
        push(ado)
      end
    end

    def build(pid)
      work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid)
      ado = OregonDigital::AspaceDigitalObject.new(work)
      ado.build_record
      ado
    end

    def push(ado)
      if ado.errors.empty?
        result[:digital_objects] << ado.record
      else
        errors << ado.errors
      end
    end

    def write_file
      Zip::File.open(zip_path, create: true) do |zip_file|
        output = "#{@importer.name}.json"
        zip_file.get_output_stream(output) do |f|
          f.write format_result
        end
      end
    end

    def mail_subject
      "digital objects in #{@importer.name}"
    end

    def download_url
      URI.join(Rails.application.routes.url_helpers.root_url, "importers/#{@importer.id}/download_do").to_s
    end

    def zip_path
      File.join(OD2::Application.config.local_path, 'export_do', "export_#{@importer.name}_do.zip")
    end

    def format_result
      result[:errors] = errors
      JSON.generate(@result)
    end

    def errors
      @errors ||= []
    end

    def result
      @result ||= { digital_objects: [] }
    end
  end
end
