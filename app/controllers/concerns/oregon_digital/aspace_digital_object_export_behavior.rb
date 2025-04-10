# frozen_string_literal: true

module OregonDigital
  # Export properties needed for creating new digital objects in ArchivesSpace.
  module AspaceDigitalObjectExportBehavior
    def show_do_export
      @importer = Bulkrax::Importer.find(params[:importer_id])
      render json: export
    end

    def export
      process_entries
      format_result
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
      ado = OregonDigital::AspaceDigitalObject.new(pid)
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

    def format_result
      result[:errors] = errors
      JSON.dump(result)
    end

    def errors
      @errors ||= []
    end

    def result
      @result ||= { digital_objects: [] }
    end
  end
end
