# frozen_string_literal:true

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
  config.crosswalk_overrides_file = ENV['CROSSWALK_OVERRIDES_FILE']

  # The crosswalk file for associating primary sets in OD1 with admin sets in OD2
  config.crosswalk_admin_sets_file = File.join(Rails.root, 'config/initializers/migrator/crosswalk_admin_sets.yml')

  # The list of required fields
  config.required_fields_file = "config/initializers/migrator/required_fields.yml"

  # Set to true for debugging
  config.skip_field_mode = ENV['SKIP_FIELD_MODE']
  # Skip content if not found
  config.content_file_can_be_nil = ENV['CONTENT_FILE_CAN_BE_NIL']

  config.upload_storage_service = :file_system
  config.ingest_storage_service = :file_system
  # The service used to upload files ready for migration. It defaults to file_system for test and development. On production, it defaults to aws_s3
  # config.upload_storage_service = if Rails.env.production?
  #                                   :aws_s3
  #                                 else
  #                                   :file_system
  #                                 end

  config.fields_map = "config/initializers/migrator/fields_map.yml"

  # The destination file system path used mainly for :file_system storage during file uploads. It defaults to environment BROWSEEVERYTHING_FILESYSTEM_PATH.
  config.file_system_path = ENV['BROWSEEVERYTHING_FILESYSTEM_PATH']

  # The service used to ingest bags during migration. It defaults to file_system for test and development. On production, it defaults to aws_s3
  # config.ingest_storage_service = if Rails.env.production?
  #                                   :aws_s3
  #                                 else
  #                                   :file_system
  #                                 end

  # The file system path used mainly for :file_system storage during mass ingest. It defaults to environment INGEST_LOCAL_PATH.
  config.ingest_local_path = ENV['INGEST_LOCAL_PATH']

  # The AWS S3 bucket used for :aws_s3 storage during mass ingest. It defaults to environment AWS_S3_INGEST_BUCKET.
  # config.aws_s3_ingest_bucket = ENV['AWS_S3_INGEST_BUCKET']

  # The AWS S3 app key used for :aws_s3 service. It defaults to environment AWS_S3_APP_KEY.
  # config.aws_s3_app_key = ENV['AWS_S3_APP_KEY']

  # The AWS S3 app key used for :aws_s3 service. It defaults to environment AWS_S3_APP_SECRET.
  # config.aws_s3_app_secret = ENV['AWS_S3_APP_SECRET']

  # The AWS S3 bucket (destination) used for :aws_s3 storage service during file uploads. It defaults to environment AWS_S3_BUCKET
  # config.aws_s3_bucket = ENV['AWS_S3_BUCKET']

  # The AWS S3 region (destination) used for :aws_s3 service. It defaults to environment AWS_S3_REGION
  # config.aws_s3_region = ENV['AWS_S3_REGION']

  # The time a presigned_url is available after the upload in seconds (aws_s3 service). It defaults to 86400 seconds (24 hours).
  # config.aws_s3_url_availability = 86400

  # VerifyWorkService uses this config as the default list of verifications to run
  config.verify_services = [
    Hyrax::Migrator::Services::VerifyMetadataService,
    Hyrax::Migrator::Services::VerifyVisibilityService,
    Hyrax::Migrator::Services::VerifyChecksumsService,
    Hyrax::Migrator::Services::VerifyChildrenService,
    Hyrax::Migrator::Services::VerifyDerivativesService,
    Hyrax::Migrator::Services::VerifyLabelsExistService
  ]
end
