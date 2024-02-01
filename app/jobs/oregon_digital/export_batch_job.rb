# frozen_string_literal: true

# based on Bulkrax::ExportWorkJob, but is meant to be run async
# uses the Hyrax::Lockable methods to prevent race condition
# Note that the original job uses increment/decrement methods that directly
# hit mysql, and presumably are much faster than going through the record
# to compensate, batch the entry building and update the counters less frequently

module OregonDigital
  # Export a batch of works
  class ExportBatchJob < ApplicationJob
    include Hyrax::Lockable
    queue_as :export

    # args[0] is an array of works [[id, entry_class]]
    # args[1] is the exporter run id
    # the logic is similar to Bulkrax::ExportWorkJob, so keeping the complexity
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def perform(*args)
      exporter_run = Bulkrax::ExporterRun.find(args[1])
      parser = exporter_run.exporter.parser
      failed = 0
      completed = 0
      tried = 0
      args[0].each do |item|
        entry = parser.find_or_create_entry(item[1].strip.constantize, item[0], 'Bulkrax::Exporter')
        begin
          entry.build
          entry.save
        rescue StandardError => e
          failed += 1
          tried += 1
          Rails.logger.info(e.message)
        else
          if entry.failed?
            failed += 1
            tried += 1
            Rails.logger.info(entry.reload.current_status.error_class.constantize)
          else
            tried += 1
            completed += 1
          end
        end
      end
      update_exporter_run(exporter_run, failed, tried, completed)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # do all of the counter updates inside the lock.
    def update_exporter_run(exporter_run, failed, tried, completed)
      acquire_lock_for("exporter_run-#{exporter_run.id}") do
        exporter_run.reload
        exporter_run.failed_records += failed
        new_enqueued = exporter_run.enqueued_records - tried
        exporter_run.enqueued_records = new_enqueued.positive? ? new_enqueued : 0
        exporter_run.processed_records += completed
        exporter_run.save
        wrap_up(exporter_run) unless new_enqueued.positive?
      end
    end

    def wrap_up(exporter_run)
      if exporter_run.failed_records.positive?
        exporter_run.exporter.set_status_info('Complete (with failures)')
      else
        exporter_run.exporter.set_status_info('Complete')
      end
      OregonDigital::ExporterWriteJob.perform_later(exporter_run.id)
    end
  end
end
