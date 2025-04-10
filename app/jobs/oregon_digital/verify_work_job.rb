# frozen_string_literal: true

module OregonDigital
  ##
  # The job responsible for initiating verifying a work
  class VerifyWorkJob < ApplicationJob
    queue_as :verify

    # rubocop:disable Style/GuardClause
    after_perform do |job|
      args = job.arguments.first
      count = Redis.current.incr("verify_count:#{args[:batch_id]}")
      if count == args[:size]
        follow_up(args)
        Redis.current.expire("verify_count:#{args[:batch_id]}", 5)
      end
    end

    def perform(args)
      service = OregonDigital::VerifyWorkService.new(args)
      service.run
    end

    def follow_up(args)
      unless args[:reporter].nil?
        datetime_today = Time.zone.now.strftime('%Y%m%d%H%M') # '201710211259'
        reporter = args[:reporter].constantize.new(args[:batch_id], datetime_today)
        reporter.write_report
        reporter.notify_user(args[:user_mail])
      end
    end
    # rubocop:enable Style/GuardClause
  end
end
