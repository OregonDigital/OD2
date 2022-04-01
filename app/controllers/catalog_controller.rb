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

  blacklight_config do
    config.add_facet_field 'open_access', limit: 5, label: 'Open Access', show: false, query: {
      open: { label: 'Open', fq: 'license_sim:(
        https\://creativecommons.org/licenses/by/4.0/ OR
        https\://creativecommons.org/licenses/by-sa/4.0/ OR
        https\://creativecommons.org/licenses/by-nd/4.0/ OR
        https\://creativecommons.org/licenses/by-nc/4.0/ OR
        https\://creativecommons.org/licenses/by-nc-nd/4.0/ OR
        https\://creativecommons.org/licenses/by-nc-sa/4.0/ OR
        http\://creativecommons.org/publicdomain/zero/1.0/ OR
        http\://creativecommons.org/publicdomain/mark/1.0/)' }
    }

    config.add_facet_field 'copyright_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.copyright_combined'), limit: 5
    config.add_facet_field 'file_format_sim', label: I18n.translate('simple_form.labels.defaults.file_format'), limit: 5
    config.add_facet_field 'resource_type_label_sim', label: I18n.translate('simple_form.labels.defaults.resource_type_label'), limit: 5
    config.add_facet_field 'topic_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.topic_combined'), limit: 5
    config.add_facet_field 'creator_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.creator_combined'), limit: 5
    config.add_facet_field 'date_combined_year_label_ssim', label: I18n.translate('simple_form.labels.defaults.date_year_combined'), limit: 5, range: { segments: false }, include_in_advanced_search: false
    config.add_facet_field 'date_combined_decade_label_ssim', label: I18n.translate('simple_form.labels.defaults.date_decade_combined'), limit: 5
    config.add_facet_field 'location_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.location_combined'), limit: 5
    config.add_facet_field 'workType_label_sim', label: I18n.translate('simple_form.labels.defaults.workType'), limit: 5
    config.add_facet_field 'language_label_sim', label: I18n.translate('simple_form.labels.defaults.language'), limit: 5
    config.add_facet_field 'non_user_collections_ssim', limit: 5, label: 'Collection'
    config.add_facet_field 'institution_label_sim', limit: 5, label: 'Institution'
    config.add_facet_field 'full_size_download_allowed_label_sim', label: I18n.translate('simple_form.labels.defaults.full_size_download_allowed'), limit: 5

    (Generic::ORDERED_PROPERTIES + Generic::UNORDERED_PROPERTIES).each do |prop|
      label = prop[:name_label].nil? ? prop[:name].sub('_label', '') : prop[:name_label]
      config.add_facet_field "#{prop[:name]}_sim", label: I18n.translate("simple_form.labels.defaults.#{label}"), show: false if prop[:collection_facetable] && !config.facet_fields.keys.include?("#{prop[:name]}_sim")
    end

    config.add_facet_fields_to_solr_request!
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end
end
