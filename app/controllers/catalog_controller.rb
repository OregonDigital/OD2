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
    uo_admin_set_ids = YAML.load_file("#{Rails.root}/config/download_restriction.yml")['uo']['admin_sets']
    visibility = ['open']
    visibility << 'uo' if current_user.role?(current_ability.uo_roles)
    visibility << 'osu' if current_user.role?(current_ability.osu_roles)
    blacklight_config.configure do |config|
      config.add_facet_field 'full_size_download_allowed', label: 'Full Size Download Allowed', query: {
          # BIG SOLR QUERY HERE
          true: { label: 'Allowed', fq:
            "full_size_download_allowed_tesim:(true)
              OR (
                visibility_ssi:(#{visibility.join ' '})
                AND -primarySet_ssim:(#{uo_admin_set_ids.join ' '})
                AND (
                  read_access_group_ssim:(#{current_user.roles.to_a.map(&:name).join ' '})
                  OR read_access_person_ssim:(#{current_user.name})
                )
                AND -full_size_download_allowed_tesim:(false)
              )"
            # )
          },
          false: { label: 'Disallowed', fq:
            "full_size_download_allowed_tesim:(false)
            OR (
              (
                *:* -visibility_ssi:(#{visibility.join ' '})
                OR primarySet_ssim:(#{uo_admin_set_ids.join ' '})
                OR (
                  *:* -read_access_group_ssim:(#{current_user.roles.to_a.map(&:name).join ' '})
                  AND *:* -read_access_person_ssim:(#{current_user.name})
                )
              )
              AND -full_size_download_allowed_tesim:(true)
            )"
          }
        }

      # BREAK
    end
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
end
