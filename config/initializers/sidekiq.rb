# frozen_string_literal:true

require 'sidekiq/web'
require 'sidekiq_queue_metrics'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
Sidekiq::Web.set :sessions,       Rails.application.config.session_options

Sidekiq::QueueMetrics.max_recently_failed_jobs = 100

config = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access

redis_conn = { url: "redis://#{config[:host]}:#{config[:port]}/" }

Sidekiq.configure_server do |s|
  s.redis = redis_conn
  Sidekiq::QueueMetrics.init(s)
end

Sidekiq.configure_client do |s|
  s.redis = redis_conn
end
