# frozen_string_literal:true

require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
Sidekiq::Web.set :sessions,       Rails.application.config.session_options

config = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access

redis_conn = { url: "redis://#{config[:host]}:#{config[:port]}/" }

Sidekiq.configure_server do |s|
  s.redis = redis_conn
  Yabeda::Prometheus::Exporter.start_metrics_server!
end

Sidekiq.configure_client do |s|
  s.redis = redis_conn
end

# Override specific job queues
#CreateDerivativeJob.queue_as :ingest
#CreateWorkJob.queue_as :ingest
#AttachFilesToWorkJob.queue_as :ingest
#EventJob.queue_as :events
#CharacterizeJob.queue_as :ingest
#StreamNotificationsJob.queue_as :notify
