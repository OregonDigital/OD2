# frozen_string_literal:true

require 'sidekiq-limit_fetch'
require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
Sidekiq::Web.set :sessions,       Rails.application.config.session_options
Sidekiq::Web.class_eval do
  use Rack::Protection, origin_whitelist: ENV.fetch('SIDEKIQ_ADMIN_SAFE_URLS', '').split(',')
end

config = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access

redis_conn = { url: "redis://#{config[:host]}:#{config[:port]}/" }

Sidekiq.configure_server do |s|
  s.redis = redis_conn
end

Sidekiq.configure_client do |s|
  s.redis = redis_conn
end
