# frozen_string_literal:true

# This controller drives the configuration of the applications searching
# indexing, displays, and other various discovery methods
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include BlacklightRangeLimit::ControllerOverride
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior

  add_breadcrumb 'Home'.html_safe, :root_path

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  # Combine our search queries as they come in
  def index
    create_full_size_download_facet
    params[:q] = params[:q].join(' AND ') if params[:q].respond_to?('join')
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
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def create_full_size_download_facet
    # Admin sets we're going to prevent downloading
    uo_admin_set_ids = YAML.load_file("#{Rails.root}/config/download_restriction.yml")['uo']['admin_sets']
    # Use open and all visibilities allowed by the current user's group
    visibility = ['open'] + current_user&.groups
    roles = ['public'] + current_user&.roles.to_a.map(&:name)

    blacklight_config.configure do |config|
      config.add_facet_field 'full_size_download_allowed', label: 'Full Size Download Allowed', query: {
        # BIG SOLR QUERY HERE
        allowed: {
          label: 'Allowed',
          fq: "full_size_download_allowed_tesim:(true)
            OR (
              (
                visibility_ssi:(#{visibility.join ' '})
                OR read_access_group_ssim:(#{roles.join ' '})
                OR read_access_person_ssim:(#{current_user&.name || 0})
              )
              AND *:* -primarySet_ssim:(#{uo_admin_set_ids.join ' '})
              AND *:* -full_size_download_allowed_tesim:(false)
            )"
        }
        # Reverse query for debugging
        # disallowed: { label: 'Disallowed', fq:
        #   "full_size_download_allowed_tesim:(false)
        #   OR (
        #     (
        #       (
        #         *:* -visibility_ssi:(#{visibility.join ' '})
        #         AND *:* -read_access_group_ssim:(#{roles.join ' '})
        #         AND *:* -read_access_person_ssim:(#{current_user.name})
        #       )
        #       OR primarySet_ssim:(#{uo_admin_set_ids.join ' '})
        #     )
        #     AND -full_size_download_allowed_tesim:(true)
        #   )"
        # }
      }
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
