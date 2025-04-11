# frozen_string_literal: true

module OregonDigital
  # adds custom behavior to bulkrax importer
  module ImporterControllerBehavior
    def work_ids
      ids = []
      @importer.entries.pluck(:identifier).each do |i|
        id = Hyrax::SolrService.query("bulkrax_identifier_sim:#{i}", fl: 'id', rows: 1).map { |x| x['id'] }.first
        ids << { work_id: id, entry_identifier: i }
      end
      ids
    end

    # show_errors?importer_id=9&time=202504011111
    def show_errors
      render file: report_path, layout: false, content_type: 'application/json'
    end

    def report_path
      File.join(OD2::Application.config.local_path, "verify/batch_#{params[:importer_id]}_report_#{params[:time]}.json")
    end

    def verify
      @importer = Bulkrax::Importer.find(params[:importer_id])
      ids = work_ids.map { |x| x[:work_id] }.reject(&:nil?)
      bvs = OregonDigital::BatchVerificationService.new(ids, { batch_id: @importer.id, user_mail: current_user.email, size: ids.size, reporter: 'OregonDigital::ImporterVerificationReporter' })
      bvs.verify
      redirect_to importer_path(@importer.id), notice: 'Verification jobs are enqueued. Jobs may be delayed depending on number/type of jobs already enqueued; an email will be sent to you when the report is complete.'
    end

    def importers_list
      render 'oregon_digital/importer/importers_list'
    end
  end
end
