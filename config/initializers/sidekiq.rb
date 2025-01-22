# frozen_string_literal:true

require 'sidekiq/web'

config = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access

redis_conn = { url: "redis://#{config[:host]}:#{config[:port]}/" }

Sidekiq.configure_server do |s|
  s.redis = redis_conn

  # TODO: Sidekiq no longer supports queue generation in initializers. Find a way to generate queues through ENV VARS in config yaml

  # If SIDEKIQ_QUEUES exists, populate :queues
  # If not, generate a default for :queues
  # if ENV["SIDEKIQ_QUEUES"]
  #   queues = []
  #   ENV["SIDEKIQ_QUEUES"].split(/\s+/).each do |queue_weighted|
  #     queue, count = queue_weighted.split(",")
  #     count = count.to_i
  #     [count, 1].max.times do
  #       queues.push(queue)
  #     end
  #   end

  #   s.options[:queues] = queues
  # else
  #   s.options[:queues] = ["notify","fetch","ingest","reindex","default","import","export","verify"]
  # end
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
