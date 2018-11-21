# config/initializers/honeycomb.rb

require 'libhoney'
key = ENV.fetch('HONEYCOMB_KEY')
dataset = ENV.fetch('HONEYCOMB_DS', 'od2-rails')

if %w[production staging].include? Rails.env
  $libhoney = Libhoney::Client.new(
    writekey: key,
    dataset: dataset,
    user_agent_addition: HoneycombRails::USER_AGENT_SUFFIX,
  )

  HoneycombRails.configure do |conf|
    conf.writekey = key
    conf.dataset = dataset
    conf.db_dataset = dataset + "-db"
    conf.client = $libhoney
  end
end
