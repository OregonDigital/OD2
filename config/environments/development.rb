# frozen_string_literal:true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = {
    host: ENV.fetch('DEFAULT_URL_OPTION', 'localhost:3000'),
    protocol: ENV.fetch('DEFAULT_URL_OPTION_PROTOCOL', 'http')
  }

  config.action_mailer.perform_caching = false

  # Don't actually send emails in development
  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = { :location => Rails.root.join('tmp/mail') }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_job.queue_adapter = ENV.fetch('ACTIVE_JOB_QUEUE_ADAPTER', 'inline').to_sym

  config.reindex_extent = ENV["MIGRATION_REINDEX_EXTENT"].present? ? 'limited' : 'full'

  # Whitelist docker containers for webconsole during development
  config.web_console.whitelisted_ips = ['172.0.0.0/8', '192.0.0.0/8']

  # Fix errors eg Psych::DisallowedClass: Tried to load unspecified class: Symbol
  config.active_record.yaml_column_permitted_classes = [Symbol, ActiveSupport::HashWithIndifferentAccess, Time]

  config.large_export_size = ENV.fetch('BULKRAX_LARGE_EXPORT', 5000).to_i
  config.batch_size = ENV.fetch('BULKRAX_BATCH_SIZE', 100).to_i


end
