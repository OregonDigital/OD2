# frozen_string_literal:true

# This controller drives the configuration of the applications searching
# indexing, displays, and other various discovery methods
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include BlacklightRangeLimit::ControllerOverride
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include BlacklightOaiProvider::Controller

  add_breadcrumb 'Home'.html_safe, :root_path

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  # Redirect for Bot Detection while ignoring OAI
  before_action except: :oai do |controller|
    BotDetectionController.bot_detection_enforce_filter(controller) unless valid_bot? # oregon-explorer.apps.geocortex.com tools.oregonexplorer.info oregondigital.org staging.oregondigital.org test.lib.oregonstate.edu:3000
  end

  # 'ir.library.oregonstate.edu,ir-staging.library.oregonstate.edu,test.lib.oregonstate.edu:3000'
  def valid_bot?
    ENV.fetch('URI_TURNSTILE_BYPASS', '').split(',').include?(request.domain) || allow_listed_ip_addr?
  end

  def allow_listed_ip_addr?
    ips = ENV.fetch('IP_TURNSTILE_BYPASS', '') # '127.0.0.1-127.255.255.255,66.249.64.0-66.249.79.255'
    ranges = ips.split(',')
    ranges.each do |range|
      range = range.split('-')
      range = (IPAddr.new(range[0]).to_i..IPAddr.new(range[1]).to_i)
      return true if range.include?(IPAddr.new(request.remote_ip).to_i)
    end
    false
  end

  # Combine our search queries as they come in
  def index
    # Dynamically add in SOLR query to the facet
    facet = blacklight_config.facet_fields['full_size_download_allowed']
    facet.query['allowed'][:fq] = full_size_download_facet_query
    blacklight_config.facet_fields['full_size_download_allowed'] = facet
    super
  end

  def page_title
    title = 'Search Results'
    title += " - #{params[:q]}" if params[:q].present?
    return title
  end

  # CatalogController-scope behavior and configuration for BlacklightIiifSearch
  include BlacklightIiifSearch::Controller
  include OregonDigital::BlacklightConfigBehavior

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end

  # Create a new facet at runtime, using attributes from the current user, to determine downloadability
  # This can't be tied directly to user abilities and is deeply intertwined with solr fields
  # By nature it is long and complex
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def full_size_download_facet_query
    # Admin sets we're going to prevent downloading
    uo_admin_set_ids = YAML.load_file("#{Rails.root}/config/download_restriction.yml")['uo']['admin_sets']
    # Select visibility based on current user's group visibilities
    visibility = ['open']
    visibility << current_user.groups unless current_user.blank?
    # Add private and in review if the user is an admin
    visibility << %w[restricted private] if current_user&.role?(Ability.manager_permission_roles)
    visibility = visibility.flatten.uniq

    roles = ['public'] + current_user&.roles.to_a.map(&:name)

    # QUERY: Add in the remaining fq query dynamically for the facet to work
    <<~SOLR.squish
      full_size_download_allowed_sim:(1)
      OR (
        (
          visibility_ssi:(#{visibility.join(' ')})
          OR read_access_group_ssim:(#{roles.join(' ')})
          OR read_access_person_ssim:(#{current_user&.name || 0})
        )
        AND *:* -primarySet_ssim:(#{uo_admin_set_ids.join(' ')})
        AND *:* -full_size_download_allowed_sim:(0)
      )
    SOLR
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  # OVERRIDE FROM BLACKLIGHT: Allow and account for multiple q: query params
  # This must be on every controller that uses the layout, because it is used in
  # the header to draw Blacklight::SearchNavbarComponent (via the shared/header_navbar template)
  # @return [Blacklight::SearchState] a memoized instance of the parameter state.
  def search_state
    params[:q] = params[:q].join(' AND ') if params[:q].respond_to?('join')
    @search_state ||= search_state_class.new(params, blacklight_config, self)
  end
end
