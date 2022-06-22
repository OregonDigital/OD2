# frozen_string_literal:true

prom_mode = ENV.fetch('YABEDA_PROMETHEUS_MODE', 'memory')

if %w[dfs direct directfilestore].include? prom_mode
  # Configure the prometheus client to use direct file store
  Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(dir: ENV.fetch('YABEDA_PROMETHEUS_PATH', '/tmp/prom'))
end

# Install the yabeda rails plugin
Yabeda::Rails.install!
