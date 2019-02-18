# frozen_string_literal:true

Hyrax::Migrator::Middleware.config do |config|
  # A custom ordered array of actors to process a work through migration.
  config.actor_stack = [
    Hyrax::Migrator::Actors::BagValidatorActor,
    Hyrax::Migrator::Actors::CrosswalkMetadataActor,
    Hyrax::Migrator::Actors::ModelLookupActor,
    Hyrax::Migrator::Actors::FileUploadActor,
    Hyrax::Migrator::Actors::PersistWorkActor
  ]
end

Hyrax::Migrator.config do |config|
  # The location to mount the migration application to, `migrator` would mount at http://domain/migrator
  config.mount_at = 'migrator'

  # The redis queue name for background jobs to run in
  # config.queue_name = 'hyrax_migrator'

  # Set a specific logger for the engine to use
  config.logger = Rails.logger

  # Register models for migration
  # config.register_model ::Models::Image
  config.register_model Generic
  config.register_model Image
  config.register_model Video
  config.register_model Document
  config.register_model Audio

  # Migration user
  config.migration_user = 'admin@example.org'

  # The model crosswalk used by ModelLookupService
  config.model_crosswalk = File.join(Rails.root, 'config/initializers/migrator/model_crosswalk.yml')

  # The crosswalk metadata file that lists properties and predicates
  config.crosswalk_metadata_file = File.join(Rails.root, 'config/initializers/migrator/crosswalk.yml')

  # The crosswalk overrides metadata file for properties and predicates that need special handling
  config.crosswalk_overrides_file = File.join(Rails.root, 'config/initializers/migrator/crosswalk_overrides.yml')

  config.upload_storage_service = :aws_s3

  # The service used to upload files ready for migration. It defaults to file_system for test and development. On staging and production, it defaults to aws_s3
  # config.upload_storage_service = if Rails.env.staging? || Rails.env.production?
  #                                   :aws_s3
  #                                 else
  #                                   :file_system
  #                                 end

  # The destination file system path used mainly for :file_system service. It defaults to environment BROWSEEVERYTHING_FILESYSTEM_PATH.
  # config.file_system_path = ENV['BROWSEEVERYTHING_FILESYSTEM_PATH']

  # The AWS S3 app key used for :aws_s3 service. It defaults to environment AWS_S3_APP_KEY.
  # config.aws_s3_app_key = ENV['AWS_S3_APP_KEY']

  # The AWS S3 app key used for :aws_s3 service. It defaults to environment AWS_S3_APP_SECRET.
  # config.aws_s3_app_secret = ENV['AWS_S3_APP_SECRET']

  # The AWS S3 bucket (destination) used for :aws_s3 service. It defaults to environment AWS_S3_BUCKET
  # config.aws_s3_bucket = ENV['AWS_S3_BUCKET']

  # The AWS S3 region (destination) used for :aws_s3 service. It defaults to environment AWS_S3_REGION
  # config.aws_s3_region = ENV['AWS_S3_REGION']

  # The time a presigned_url is available after the upload in seconds (aws_s3 service). It defaults to 86400 seconds (24 hours).
  # config.aws_s3_url_availability = 86400

end