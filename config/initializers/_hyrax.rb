# frozen_string_literal:true

# Configuration hack for recaptcha
Hyrax::Configuration.class_eval do
  attr_writer :recaptcha
  attr_reader :recaptcha
  def recaptcha?
    @recaptcha ||= false
  end

  attr_writer :recaptcha_site_key
  attr_reader :recaptcha_site_key

  attr_writer :recaptcha_secret_key
  attr_reader :recaptcha_secret_key
end

Hyrax.config do |config|
  # Injected via `rails g hyrax:work Generic`
  config.register_curation_concern :generic
  # Injected via `rails g hyrax:work Image`
  config.register_curation_concern :image
  # Injected via `rails g hyrax:work Video`
  config.register_curation_concern :video
  # Injected via `rails g hyrax:work Document`
  config.register_curation_concern :document
  # Injected via `rails g hyrax:work Audio`
  config.register_curation_concern :audio
  # Register roles that are expected by your implementation.
  # @see Hyrax::RoleRegistry for additional details.
  # @note there are magical roles as defined in Hyrax::RoleRegistry::MAGIC_ROLES
  # config.register_roles do |registry|
  #   registry.add(name: 'captaining', description: 'For those that really like the front lines')
  # end

  # When an admin set is created, we need to activate a workflow.
  # The :default_active_workflow_name is the name of the workflow we will activate.
  # @see Hyrax::Configuration for additional details and defaults.
  # config.default_active_workflow_name = 'default'

  # Which RDF term should be used to relate objects to an admin set?
  # If this is a new repository, you may want to set a custom predicate term here to
  # avoid clashes if you plan to use the default (dct:isPartOf) for other relations.
  RDF::VOCABS.merge!({ons: {uri: "http://opaquenamespace.org/ns/", class_name: "ONS"}})
  config.admin_set_predicate = RDF::Vocabulary.new("http://opaquenamespace.org/ns/").primarySet

  # Email recipient of messages sent via the contact form
  config.contact_email = ENV.fetch('SYSTEM_EMAIL_ADDRESS', 'noreply@oregondigital.org')

  # Text prefacing the subject entered in the contact form
  config.subject_prefix = "Oregon Digital Contact Request - "

  # How many notifications should be displayed on the dashboard
  # config.max_notifications_for_dashboard = 5

  # How frequently should a file be fixity checked
  # config.max_days_between_fixity_checks = 7

  # Options to control the file uploader
  # config.uploader = {
  #   limitConcurrentUploads: 6,
  #   maxNumberOfFiles: 100,
  #   maxFileSize: 500.megabytes
  # }

  # Enable displaying usage statistics in the UI
  # Defaults to false
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = true

  # Google Analytics tracking ID to gather usage statistics
  config.google_analytics_id = ENV.fetch('GOOGLE_ANALYTICS_ID', nil)

  # Date you wish to start collecting Google Analytic statistics for
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  config.analytic_start_date = DateTime.new(2023, 2, 13)

  # Enables a link to the citations page for a work
  # Default is false
  config.citations = true

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # Hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # If you have ffmpeg installed and want to transcode audio and video set to true
  config.enable_ffmpeg = true

  # Hyrax uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Use the database-backed minter class
  # config.noid_minter_class = ActiveFedora::Noid::Minter::Db

  # Store identifier minter's state in a file for later replayability
  # config.minter_statefile = '/tmp/minter-state'

  # Prefix for Redis keys
  # config.redis_namespace = "hyrax"

  # Path to the file characterization tool
  # config.fits_path = "fits.sh"
  config.fits_path = ENV.fetch('FITS_PATH', 'fits.sh')

  # Path to the file derivatives creation tool
  # config.libreoffice_path = "soffice"

  # Option to enable/disable full text extraction from PDFs
  # Default is true, set to false to disable full text extraction
  config.extract_full_text = true

  # How many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Hyrax can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Stream realtime notifications to users in the browser
  config.realtime_notifications = false

  # Location autocomplete uses geonames to search for named regions
  # Username for connecting to geonames
  config.geonames_username = ENV.fetch('GEONAMES_USERNAME', 'etsdev')

  # Should the acceptance of the licence agreement be active (checkbox), or
  # implied when the save button is pressed? Set to true for active
  # The default is true.
  # config.active_deposit_agreement_acceptance = true

  # Should work creation require file upload, or can a work be created first
  # and a file added at a later time?
  # The default is true.
  # config.work_requires_files = true

  # Should a button with "Share my work" show on the front page to all users (even those not logged in)?
  config.display_share_button_when_not_logged_in = false

  # The user who runs batch jobs. Update this if you aren't using emails
  # config.batch_user_key = 'batchuser@example.com'

  # The user who runs fixity check jobs. Update this if you aren't using emails
  # config.audit_user_key = 'audituser@example.com'
  #
  # The banner image. Should be 5000px wide by 1000px tall
  # config.banner_image = 'https://cloud.githubusercontent.com/assets/92044/18370978/88ecac20-75f6-11e6-8399-6536640ef695.jpg'

  # The banner uploads path, served by the webserver
  config.branding_path = Rails.root.join('public', 'branding')

  # Temporary paths to hold uploads before they are ingested into FCrepo
  # These must be lambdas that return a Pathname. Can be configured separately
  config.upload_path = -> { Rails.root.join('tmp', 'shared', 'uploads') }
  config.cache_path = -> { Rails.root.join('tmp', 'shared', 'uploads', 'cache') }

  # Location on local file system where derivatives will be stored
  # If you use a multi-server architecture, this MUST be a shared volume
  config.derivatives_path = Rails.root.join('tmp', 'shared', 'derivatives')

  # Should schema.org microdata be displayed?
  # config.display_microdata = true

  # What default microdata type should be used if a more appropriate
  # type can not be found in the locale file?
  # config.microdata_default_type = 'http://schema.org/CreativeWork'

  # Location on local file system where uploaded files will be staged
  # prior to being ingested into the repository or having derivatives generated.
  # If you use a multi-server architecture, this MUST be a shared volume.
  config.working_path = Rails.root.join('tmp', 'shared', 'uploads')

  # Should the media display partial render a download link?
  # config.display_media_download_link = true

  # A configuration point for changing the behavior of the license service
  #   @see Hyrax::LicenseService for implementation details
  # config.license_service_class = Hyrax::LicenseService

  # Labels for display of permission levels
  # config.permission_levels = { "View/Download" => "read", "Edit access" => "edit" }

  # Labels for permission level options used in dropdown menus
  # config.permission_options = { "Choose Access" => "none", "View/Download" => "read", "Edit" => "edit" }

  # Labels for owner permission levels
  # config.owner_permission_levels = { "Edit Access" => "edit" }

  # Path to the ffmpeg tool
  # config.ffmpeg_path = 'ffmpeg'

  # Max length of FITS messages to display in UI
  # config.fits_message_length = 5

  # ActiveJob queue to handle ingest-like jobs
  config.ingest_queue_name = :ingest

  ## Attributes for the lock manager which ensures a single process/thread is mutating a ore:Aggregation at once.
  # How many times to retry to acquire the lock before raising UnableToAcquireLockError
  # config.lock_retry_count = 600 # Up to 2 minutes of trying at intervals up to 200ms
  #
  # Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.
  # config.lock_retry_delay = 200
  #
  # How long to hold the lock in milliseconds
  # config.lock_time_to_live = 60_000

  ## Do not alter unless you understand how ActiveFedora handles URI/ID translation
  # config.translate_id_to_uri = ActiveFedora::Noid.config.translate_id_to_uri
  # config.translate_uri_to_id = ActiveFedora::Noid.config.translate_uri_to_id

  ## Fedora import/export tool
  #
  # Path to the Fedora import export tool jar file
  # config.import_export_jar_file_path = "tmp/fcrepo-import-export.jar"
  #
  # Location where BagIt files should be exported
  # config.bagit_dir = "tmp/descriptions"

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn 'BrowseEverything is not installed'
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end

  ## Whitelist all directories which can be used to ingest from the local file
  # system.
  #
  # Any file, and only those, that is anywhere under one of the specified
  # directories can be used by CreateWithRemoteFilesActor to add local files
  # to works. Files uploaded by the user are handled separately and the
  # temporary directory for those need not be included here.
  #
  # Default value includes BrowseEverything.config['file_system'][:home] if it
  # is set, otherwise default is an empty list. You should only need to change
  # this if you have custom ingestions using CreateWithRemoteFilesActor to
  # ingest files from the file system that are not part of the BrowseEverything
  # mount point.
  #
  # config.whitelisted_ingest_dirs = []

  # Fields to display in the IIIF metadata section; default is the required fields
  config.iiif_metadata_fields = %i[
    title creator_label photographer_label arranger_label artist_label author_label
    cartographer_label collector_label composer_label contributor_label designer_label donor_label editor_label
    illustrator_label interviewee_label interviewer_label landscape_architect_label lyricist_label owner_label patron_label
    print_maker_label recipient_label transcriber_label translator_label description abstract inscription view subject_label
    award cultural_context_label ethnographic_term_label event keyword legal_name military_branch_label sports_team
    style_or_period_label phylum_or_division_label taxon_class_label order_label family_label genus_label species_label
    common_name_label location_label gps_latitude gps_longitude ranger_district_label street_address tgn_label
    water_basin_label date date_created view_date license_label rights_holder rights_note rights_statement_label
    use_restrictions repository_label local_collection_name_label language_label publisher_label provenance source has_finding_aid
    is_part_of resource_type_label workType_label measurements collections
  ]

  # Enables the use of Google ReCaptcha on the contact form.
  # A site key and secret key need to be supplied in order for google
  # to authenticate and authorize/validate the
  config.recaptcha = true
  #
  # ReCaptcha site key and secret key, supplied by google after
  # registering a domain.
  config.recaptcha_site_key = ENV.fetch('RECAPTCHA_SITE_KEY', 'xxxx_XXXXXXXXXXfffffffffff')
  # WARNING: KEEP THIS SECRET. DO NOT STORE IN REPOSITORY
  config.recaptcha_secret_key = ENV.fetch('RECAPTCHA_SECRET_KEY', 'xxxx_XXXXXXXXXXfffffffffff')



end

Date::DATE_FORMATS[:standard] = '%m/%d/%Y'

Qa::Authorities::Local.register_subauthority('subjects', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('genres', 'Qa::Authorities::Local::TableBasedAuthority')

Hyrax::Engine.routes.default_url_options = Rails.application.config.action_mailer.default_url_options
Rails.application.routes.default_url_options = Rails.application.config.action_mailer.default_url_options

Hyrax::DerivativeService.services = [OregonDigital::FileSetDerivativesService]

# set bulkrax default work type to first curation_concern if it isn't already set
if Bulkrax.default_work_type.blank?
  Bulkrax.default_work_type = Hyrax.config.curation_concerns.first.to_s
end

Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::CreateWithRemoteFilesActor, OregonDigital::Actors::CreateWithOembedUrlActor

# Add extra blacklight routes to Admin Workflows (Review Queue) controller
Hyrax::Engine.routes.prepend do
  concern :searchable, Blacklight::Routes::Searchable.new

  namespace :admin do
    resource :workflows, only: [:index], as: 'workflows', path: '/workflows', controller: 'workflows' do
      concerns :searchable
    end
  end
end
