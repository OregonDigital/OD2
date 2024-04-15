# frozen_string_literal: true

module OregonDigital
  module ImporterControllerBehavior
    def show_errors
      @importer = Bulkrax::Importer.find(params[:importer_id])
      @errors = compile_errors
      render 'oregon_digital/importer_verification/show_errors'
    end

    def verify
      @importer = Bulkrax::Importer.find(params[:importer_id])
      bvs = OregonDigital::BatchVerificationService.new(get_ids)
      bvs.verify
      redirect_to importer_path(@importer.id), notice: 'Verification jobs are enqueued.'
    end

    def get_ids
      ids = []
      @importer.entries.pluck(:identifier).each do |i|
        ids << Hyrax::SolrService.query("bulkrax_identifier_sim:#{i}", fl: 'id', rows: 1).map{|x| x['id']}.first
      end
      ids
    end

    def compile_errors
      errors = {}
      get_ids.each do |id|
        work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id)
        errors[id] = work.all_errors
      end
      errors
    end
  end
end
