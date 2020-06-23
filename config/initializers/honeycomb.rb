# Honeycomb integration

if Rails.env.development? || ENV.key?("HONEYCOMB_DEBUG")
  Honeycomb.configure do |config|
    config.client = Libhoney::NullClient.new
  end
else

  # Honeycomb Rails integration
  Honeycomb.configure do |config|
    config.write_key = ENV.fetch('HONEYCOMB_WRITEKEY', 'hereisareallylonglookingkey')
    config.dataset = ENV.fetch('HONEYCOMB_DATASET', 'od2-something-something')
    config.notification_events = %w[
      sql.active_record
      render_template.action_view
      render_collection.action_view
      process_action.action_controller
      send_file.action_controller
      send_data.action_controller
      deliver.action_mailer
    ].freeze

    # Scrub unused data to save space in Honeycomb
    config.presend_hook do |fields|

      if fields.key?("redis.command")
        fields["redis.command"] = fields["redis.command"].slice(0, 300)
      elsif fields.key?("sql.active_record.binds")
        fields.delete("sql.active_record.binds")
      end
    end
    # Sample away highly redundant events
    config.sample_hook do |fields|
      OregonDigital::NoiseCancellingSampler.sample(fields)
    end
  end
end
