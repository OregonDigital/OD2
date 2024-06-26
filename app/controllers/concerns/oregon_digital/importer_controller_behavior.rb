# frozen_string_literal: true

module OregonDigital
  # adds custom behavior to bulkrax importer
  module ImporterControllerBehavior
    def show_errors
      @importer = Bulkrax::Importer.find(params[:importer_id])
      @errors = compile_errors
      render 'oregon_digital/importer/show_errors'
    end

    def verify
      @importer = Bulkrax::Importer.find(params[:importer_id])
      bvs = OregonDigital::BatchVerificationService.new(work_ids.map { |x| x[:work_id] }.reject(&:nil?))
      bvs.verify
      redirect_to importer_path(@importer.id), notice: 'Verification jobs are enqueued. Jobs may be delayed depending on number/type of jobs already enqueued; please wait 5-10 minutes before checking results.'
    end

    # returns an array of hashes, eg { work_id: 'abcde1234', entry_identifier: '80-101' }
    # if solr returns an empty array, the work_id will be nil
    def work_ids
      ids = []
      @importer.entries.pluck(:identifier).each do |i|
        id = Hyrax::SolrService.query("bulkrax_identifier_sim:#{i}", fl: 'id', rows: 1).map { |x| x['id'] }.first
        ids << { work_id: id, entry_identifier: i }
      end
      ids
    end

    def compile_errors
      errors = {}
      work_ids.each do |item|
        if item[:work_id].nil?
          errors[item[:entry_identifier]] = { solr: ['Unable to load work for this entry.'] }
        else
          errors[item[:work_id]] = retrieve_errors(item[:work_id])
        end
      end
      errors
    end

    def retrieve_errors(id)
      work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id)
      work.all_errors
    rescue Valkyrie::Persistence::ObjectNotFoundError
      { valkyrie: ['Unable to load work.'] }
    end

    def importers_list
      render 'oregon_digital/importer/importers_list'
    end
  end
end
