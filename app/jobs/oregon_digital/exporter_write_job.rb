# frozen_string_literal: true

module OregonDigital
  # If the export is large, the exporter job will only do the export
  # Remaining tasks here, will be enqueued by the final ExportBatchJob
  class ExporterWriteJob < ApplicationJob
    queue_as :export

    def perform(exporter_run_id)
      exporter_run = Bulkrax::ExporterRun.find(exporter_run_id)
      exporter_run.exporter.write
      exporter_run.exporter.save
    end
  end
end
