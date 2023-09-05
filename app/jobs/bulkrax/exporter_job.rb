# frozen_string_literal: true

module Bulkrax
  # Adding method to cancel
  class ExporterJob < ApplicationJob
    queue_as :export

    before_perform do |job|
      if cancelled?(job.provider_job_id)
        Rails.logger.info "Job #{job.provider_job_id} is cancelled."
        throw(:abort)
      end
    end

    def perform(exporter_id)
      exporter = Exporter.find(exporter_id)
      exporter.export
      exporter.write
      exporter.save
      true
    end

    def cancelled?(jid)
      Sidekiq.redis { |c| c.exists?("cancelled-#{jid}") } # Use c.exists? on Redis >= 4.2.0
    end

    # rubocop:disable Style/NumericLiterals
    def self.cancel!(jid)
      Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 86400, 1) }
    end
    # rubocop:enable Style/NumericLiterals
  end
end
