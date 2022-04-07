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
