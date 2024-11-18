# frozen_string_literal: true

module Bulkrax
  class ExportWorkJob < ApplicationJob
    queue_as :export

    def perform(*args)
      entry = Entry.find(args[0])
      exporter_run = ExporterRun.find(args[1])
      begin
        entry.build
        entry.save
      rescue StandardError
        # rubocop:disable Rails/SkipsModelValidations
        ExporterRun.increment_counter(:failed_records, args[1])
        ExporterRun.decrement_counter(:enqueued_records, args[1]) unless exporter_run.reload.enqueued_records <= 0
        raise
      else
        if entry.failed?
          ExporterRun.increment_counter(:failed_records, args[1])
          ExporterRun.decrement_counter(:enqueued_records, args[1]) unless exporter_run.reload.enqueued_records <= 0
          raise entry.reload.current_status.error_class.constantize
        else
          ExporterRun.increment_counter(:processed_records, args[1])
          ExporterRun.decrement_counter(:enqueued_records, args[1]) unless exporter_run.reload.enqueued_records <= 0
        end
        # rubocop:enable Rails/SkipsModelValidations
      end
      return entry if exporter_run.reload.enqueued_records.positive?

      if exporter_run.failed_records.positive?
        exporter_run.exporter.set_status_info('Complete (with failures)')
      else
        exporter_run.exporter.set_status_info('Complete')
      end

      return entry
    end
  end
end
