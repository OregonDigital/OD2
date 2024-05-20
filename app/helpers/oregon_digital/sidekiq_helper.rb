# frozen_string_literal: true

require 'sidekiq/api'

module OregonDigital
  # To provide information to curators waiting for jobs to complete.
  module SidekiqHelper
    def sidekiq_jobs(queue)
      Sidekiq::Queue.new(queue).size
    end
  end
end
