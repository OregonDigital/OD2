# frozen_string_literal: true

require 'sidekiq/api'

module OregonDigital
  # To provide information to curators waiting for jobs to complete.
  module SidekiqHelper
    def sidekiq_jobs(queue)
      Sidekiq::Queue.new(queue).size
    end

    # all jobs run on the regular workers
    def sidekiq_jobs_all
      jobs = 0
      queues = %w[fetch ingest default import export verify]
      queues.each do |q|
        jobs += sidekiq_jobs(q)
      end
      jobs
    end
  end
end
