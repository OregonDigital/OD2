# frozen_string_literal:true

# Configure the prometheus client to use direct file store
Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(dir: ENV['YABEDA_PROMETHEUS_PATH'])
