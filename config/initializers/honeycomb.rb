Honeycomb.configure do |config|
  config.write_key = ENV.fetch('HONEYCOMB_WRITEKEY', 'd5529d94d4e989bb1fc1b1cfc559ebba')
  config.dataset = ENV.fetch('HONEYCOMB_DATASET', 'od2-rails-staging')
  config.notification_events = %w[
    sql.active_record
    render_template.action_view
    render_partial.action_view
    render_collection.action_view
    process_action.action_controller
    send_file.action_controller
    send_data.action_controller
    deliver.action_mailer
  ].freeze
end