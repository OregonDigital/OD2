# frozen_string_literal: true

Rails.application.config.to_prepare do
  Hyrax::ApplicationJob.class_eval do

    before_perform do |job|
      throw(:abort) if cancelled?(job.provider_job_id)
    end

    def cancelled?(jid)
      Sidekiq.redis {|c| c.exists?("cancelled-#{jid}") } # Use c.exists? on Redis >= 4.2.0
    end

    def self.cancel!(jid)
      Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
    end
  end
end


