# frozen_string_literal: true

module Bulkrax
  # Runs the build process for an entry found in a file for import
  
  class ImportWorkJob < ApplicationJob
    queue_as Bulkrax.config.ingest_queue_name

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    #
    # @note Yes, we are calling {ImporterRun.find} each time.  these were on purpose to prevent race
    #       conditions on the database update. If you do not re-find (or at least reload) the object
    #       on each increment, the count can get messed up. Let's say there are two jobs A and B and
    #       a counter set to 2.
    #
    #       - A grabs the importer_run (line 10)
    #       - B grabs the importer_run (line 10)
    #       - A Finishes the build, does the increment (now the counter is 3)
    #       - B Finishes the build, does the increment (now the counter is 3 again) and thus a count
    #         is lost.
    #
    # @see https://codingdeliberately.com/activerecord-increment/
    # @see https://github.com/samvera-labs/bulkrax/commit/5c2c795452e13a98c9217fdac81ae2f5aea031a0#r105848236
    def perform(entry_id, run_id, time_to_live = 3, *)
      entry = Entry.find(entry_id)
      entry.build
      if entry.status == 'Complete'
        ImporterRun.increment_counter(:processed_records, run_id)
        ImporterRun.increment_counter(:processed_works, run_id)
      else
        # do not retry here because whatever parse error kept you from creating a work will likely
        # keep preventing you from doing so.
        ImporterRun.increment_counter(:failed_records, run_id)
        ImporterRun.increment_counter(:failed_works, run_id)
      end
      
      # Regardless of completion or not, we want to decrement the enqueued records.
      ImporterRun.decrement_counter(:enqueued_records, run_id) unless ImporterRun.find(run_id).enqueued_records <= 0

      # OVERRIDE FROM BULKRAX
      # We need to do a small data correction before the final save for the entry.
      entry.full_size_download_allowed = entry.full_size_download_allowed.to_s if entry.respond_to?(:full_size_download_allowed)

      entry.save!
      entry.importer.current_run = ImporterRun.find(run_id)
      entry.importer.record_status
    rescue Bulkrax::CollectionsCreatedError => e
      Rails.logger.warn("#{self.class} entry_id: #{entry_id}, run_id: #{run_id} encountered #{e.class}: #{e.message}")
      # You get 3 attempts at the above perform before we have the import exception cascade into
      # the Sidekiq retry ecosystem.
      # rubocop:disable Style/IfUnlessModifier
      if time_to_live <= 1
        raise "Exhauted reschedule limit for #{self.class} entry_id: #{entry_id}, run_id: #{run_id}.  Attemping retries"
      end
      
      # rubocop:enable Style/IfUnlessModifier
      reschedule(entry_id, run_id, time_to_live)
    end
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize

    def reschedule(entry_id, run_id, time_to_live)
      ImportWorkJob.set(wait: 1.minute).perform_later(entry_id, run_id, time_to_live - 1)
    end
  end
end
