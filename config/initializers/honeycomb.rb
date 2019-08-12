Honeycomb.configure do |config|
  config.write_key = ENV.fetch('HONEYCOMB_WRITEKEY', 'hereisareallylonglookingkey')
  config.dataset = ENV.fetch('HONEYCOMB_DATASET', 'od2-something-something')
end
