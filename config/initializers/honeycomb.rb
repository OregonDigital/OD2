# config/initializers/honeycomb.rb

require 'libhoney'
key = 'fa01b2227f761b5c1f11ae1a680f14da'
dataset = "od2-rails"

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
