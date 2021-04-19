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

  def self.uploaded_field
    'system_create_dtsi'
  end

  def self.modified_field
    'system_modified_dtsi'
  end

  # Combine our search queries as they come in
  def index
    params[:q] = params[:q].join(' AND ') if params.respond_to?('join')
    super
  end

  # CatalogController-scope behavior and configuration for BlacklightIiifSearch
  include BlacklightIiifSearch::Controller

  configure_blacklight do |config|
    # configuration for Blacklight IIIF Content Search
    config.iiif_search = {
      full_text_field: 'all_text_tsimv',
      object_relation_field: 'file_set_ids_ssim',
      supported_params: %w[q page],
      autocomplete_handler: 'iiif_suggest',
      suggester_name: 'iiifSuggester'
    }
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    config.view.list.partials = %i[thumbnail index_header index]
    config.view.gallery.partials = %i[metadata]
    config.view.gallery.if = true
    config.view.slideshow.partials = %i[index]
    config.view.slideshow.if = false

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = OregonDigital::CatalogSearchBuilder
    config.http_method = :post
    config.per_page = [8, 20, 60, 100]

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      qf: "title_tesim description_tesim #{Generic.controlled_property_labels.map { |term| "#{term}_tesim" }.join(' ')} keyword_tesim"
    }

    # solr field configuration for document/show views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # Remove the view type selector (masonry, grid, list, etc) from the sort/show section so we can add it somewhere else
    config.index.collection_actions.delete_field 'view_type_group'

    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title_tesim', label: 'Title', itemprop: 'name', if: false, highlight: true
    config.add_index_field 'creator_label_sim', itemprop: 'creator', link_to_search: 'creator_label_sim', max_values: 3, max_values_label: 'others'
    config.add_index_field 'date_tesim', itemprop: 'date'
    config.add_index_field 'description_tesim', itemprop: 'description', helper_method: :iconify_auto_link_with_highlight, truncate: { list: 20, masonry: 10 }, max_values: 1, highlight: true, if: lambda { |_context, _field_config, document|
      # Only display description if a highlight is hit
      document.response['highlighting'][document.id].keys.include?('description_tesim')
    }
    config.add_index_field 'all_text_tsimv', itemprop: 'keyword', truncate: { list: 20, masonry: 10 }, max_values: 1, highlight: true, unless: lambda { |_context, _field_config, document|
      # Don't display full text if description has a highlight hit
      document.response['highlighting'][document.id].keys.include?('description_tesim')
    }, if:  lambda { |_context, _field_config, document|
      # Only try to display full text if a highlight is hit
      document.response['highlighting'][document.id].keys.include?('all_text_tsimv')
    }
    config.add_index_field 'resource_type_label_tesim', label: 'Resource Type', link_to_search: 'resource_type_label_tesim', if: false
    config.add_index_field 'rights_statement_label_tesim', label: 'Rights Statement', link_to_search: 'rights_statement_label_tesim', if: false

    config.add_field_configuration_to_solr_request!

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # Reject the non-label form of controlled vocabular terms from being searchable or indexable
    rejected_fields = Generic.controlled_property_labels.map { |field| field.gsub('_label', '') }
    rejected_fields += %w[resource_type license language oembed_url]

    search_fields = []
    # Add all fields as searchable, reject the non-searchable fields
    Document.document_properties.reject { |attr| rejected_fields.include? attr }.each do |prop|
      # Skip if this property isn't indexed
      next if Document.properties[prop].behaviors.nil? || Generic.properties.key?(prop)

      # Skip if the property isnt stored searchable
      next unless Document.properties[prop].behaviors.include?(:stored_searchable)

      # Add property as searchable all fields box and individually
      config.add_show_field solr_name(prop, :stored_searchable) if Document.properties[prop]['showable'] || Document.properties[prop]['showable'].nil?
      next unless Document.properties[prop]['basic_searchable'] || Document.properties[prop]['basic_searchable'].nil?

      config.add_search_field(prop) do |field|
        solr_name = solr_name(prop, :stored_searchable)
        search_fields << solr_name
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
        field.include_in_advanced_search = false
      end
    end
    Generic.generic_properties.reject { |attr| rejected_fields.include? attr }.each do |prop|
      # Skip if this property isn't indexed
      next if Generic.properties[prop].behaviors.nil?

      # Skip if the property isnt stored searchable
      next unless Generic.properties[prop].behaviors.include?(:stored_searchable)

      config.add_show_field solr_name(prop, :stored_searchable) if Generic.properties[prop]['showable'] || Generic.properties[prop]['showable'].nil?
      next unless Generic.properties[prop]['basic_searchable'] || Generic.properties[prop]['basic_searchable'].nil?

      config.add_search_field(prop) do |field|
        solr_name = solr_name(prop, :stored_searchable)
        search_fields << solr_name
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
        field.include_in_advanced_search = false
      end
    end
    Image.image_properties.reject { |attr| rejected_fields.include? attr }.each do |prop|
      # Skip if this property isn't indexed
      next if Image.properties[prop].behaviors.nil? || Generic.properties.key?(prop)

      # Skip if the property isnt stored searchable
      next unless Image.properties[prop].behaviors.include?(:stored_searchable)

      config.add_show_field solr_name(prop, :stored_searchable) if Image.properties[prop]['showable'] || Image.properties[prop]['showable'].nil?
      next unless Image.properties[prop]['basic_searchable'] || Image.properties[prop]['basic_searchable'].nil?

      config.add_search_field(prop) do |field|
        solr_name = solr_name(prop, :stored_searchable)
        search_fields << solr_name
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
        field.include_in_advanced_search = false
      end
    end
    # WE MAY NEED TO ADD VIDEO BACK HERE IF ITS METADATA CHANGES DOWN THE LINE
    #
    #
    ##########################################################################
    Generic.controlled_property_labels.each do |label|
      prop = label.gsub('_label', '')

      # Skip if this property isn't indexed
      next if Generic.properties[prop].behaviors.nil?

      # Skip if the property isnt stored searchable
      next unless Generic.properties[prop].behaviors.include?(:stored_searchable)

      config.add_show_field solr_name(label, :stored_searchable) if Generic.properties[prop]['showable'] || Generic.properties[prop]['showable'].nil?
      next unless Generic.properties[prop]['basic_searchable'] || Generic.properties[prop]['basic_searchable'].nil?

      config.add_search_field(label) do |field|
        solr_name = solr_name(label, :stored_searchable)
        search_fields << solr_name(label, :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
        field.include_in_advanced_search = false
      end
    end
    config.add_show_field 'resource_type_label_tesim'
    config.add_show_field 'language_label_tesim'

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
    config.add_facet_field 'date_combined_year_label_ssim', label: I18n.translate('simple_form.labels.defaults.date_year_combined'), limit: 5, range: true, include_in_advanced_search: false
    config.add_facet_field 'date_combined_decade_label_ssim', label: I18n.translate('simple_form.labels.defaults.date_decade_combined'), limit: 5
    config.add_facet_field 'location_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.location_combined'), limit: 5
    config.add_facet_field 'workType_label_sim', label: I18n.translate('simple_form.labels.defaults.workType'), limit: 5
    config.add_facet_field 'language_label_sim', label: I18n.translate('simple_form.labels.defaults.language'), limit: 5
    config.add_facet_field 'non_user_collections_ssim', limit: 5, label: 'Collection'
    config.add_facet_field 'institution_label_sim', limit: 5, label: 'Institution'
    config.add_facet_field 'full_size_download_allowed_label_sim', label: I18n.translate('simple_form.labels.defaults.full_size_download_allowed'), limit: 5

    # Iterate all metadata and facet the properties that are configured for facets and not facetable yet
    # Do not show these facets, they're for collection configurable facets
    (Generic::ORDERED_PROPERTIES + Generic::UNORDERED_PROPERTIES).each do |prop|
      label = prop[:name_label].nil? ? prop[:name].sub('_label', '') : prop[:name_label]
      config.add_facet_field "#{prop[:name]}_sim", label: I18n.translate("simple_form.labels.defaults.#{label}"), show: false if prop[:collection_facetable] && !config.facet_fields.keys.include?("#{prop[:name]}_sim")
    end

    config.add_facet_fields_to_solr_request!

    # 'fielded' search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # Type and Language is an edge case that is controlled by not as a typical ControlledVocabulary
    config.add_search_field('resource_type_label') do |field|
      solr_name = 'resource_type_label_tesim'
      search_fields << 'resource_type_label_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end
    config.add_search_field('language_label') do |field|
      solr_name = 'language_label_tesim'
      search_fields << 'language_label_tesim'
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = search_fields.join(' ')
      title_name = 'title_tesim'
      field.solr_parameters = {
        qf: "#{all_names} #{title_name} license_label_tesim rights_statement_label_tesim file_format_sim all_text_tsimv",
        pf: title_name.to_s
      }
      field.include_in_advanced_search = false
    end
    # Advanced search fields
    config.add_search_field('title_desc_field', label: 'Title / Description') do |field|
      title_name = 'title_tesim'
      field.solr_parameters = {
        qf: "#{title_name} description_tesim",
        pf: title_name.to_s
      }
    end
    config.add_search_field('creator_field', label: 'Creator') do |field|
      solr_name = 'creator_combined_label_sim'
      search_fields << solr_name
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end
    # 'sort results by' select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: 'relevance'
    config.add_sort_field "#{uploaded_field} desc", label: 'date uploaded (desc)'
    config.add_sort_field "#{uploaded_field} asc", label: 'date uploaded (asc)'
    config.add_sort_field "#{modified_field} desc", label: 'date modified (desc)'
    config.add_sort_field "#{modified_field} asc", label: 'date modified (asc)'

    # If there are more than this many search results, no spelling ('did you
    # mean') suggestion is offered.
    config.spell_max = 5
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end
end
