# frozen_string_literal:true

# This controller drives the configuration of the applications searching
# indexing, displays, and other various discovery methods
class CatalogController < ApplicationController
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    solr_name('system_create', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('system_modified', :stored_sortable, type: :date)
  end

  configure_blacklight do |config|
    config.view.gallery.partials = %i[index_header index]
    config.view.masonry.partials = %i[index]
    config.view.slideshow.partials = %i[index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = Hyrax::CatalogSearchBuilder
    config.http_method = :post

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      qf: 'title_tesim description_tesim creator_tesim keyword_tesim'
    }

    # solr field configuration for document/show views
    config.index.title_field = solr_name('title', :stored_searchable)
    config.index.display_type_field = solr_name('has_model', :symbol)
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field solr_name('human_readable_type', :facetable), label: 'Type', limit: 5
    config.add_facet_field solr_name('file_format', :facetable), limit: 5
    config.add_facet_field solr_name('member_of_collections', :symbol), limit: 5, label: 'Collections'

    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field solr_name('generic_type', :facetable), if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name('title', :stored_searchable), label: 'Title', itemprop: 'name', if: false
    config.add_index_field solr_name('description', :stored_searchable), itemprop: 'description', helper_method: :iconify_auto_link
    config.add_index_field solr_name('keyword', :stored_searchable), itemprop: 'keywords', link_to_search: solr_name('keyword', :facetable)
    config.add_index_field solr_name('subject_label', :stored_searchable), itemprop: 'about', link_to_search: solr_name('subject_label', :facetable)
    config.add_index_field solr_name('creator_label', :stored_searchable), itemprop: 'creator', link_to_search: solr_name('creator_label', :facetable)
    config.add_index_field solr_name('contributor_label', :stored_searchable), itemprop: 'contributor', link_to_search: solr_name('contributor_label', :facetable)
    config.add_index_field solr_name('proxy_depositor', :symbol), label: 'Depositor', helper_method: :link_to_profile
    config.add_index_field solr_name('depositor'), label: 'Owner', helper_method: :link_to_profile
    config.add_index_field solr_name('publisher_label', :stored_searchable), itemprop: 'publisher', link_to_search: solr_name('publisher', :facetable)
    config.add_index_field solr_name('based_near_label', :stored_searchable), itemprop: 'contentLocation', link_to_search: solr_name('based_near_label', :facetable)
    config.add_index_field solr_name('language_label', :stored_searchable), itemprop: 'inLanguage', link_to_search: solr_name('language', :facetable)
    config.add_index_field solr_name('date_uploaded', :stored_sortable, type: :date), itemprop: 'datePublished', helper_method: :human_readable_date
    config.add_index_field solr_name('date_modified', :stored_sortable, type: :date), itemprop: 'dateModified', helper_method: :human_readable_date
    config.add_index_field solr_name('date_created', :stored_searchable), itemprop: 'dateCreated'
    config.add_index_field solr_name('rights_statement_label', :stored_searchable), helper_method: :rights_statement_links
    config.add_index_field solr_name('license_label', :stored_searchable), helper_method: :license_links
    config.add_index_field solr_name('type_label', :stored_searchable), label: 'Resource Type', link_to_search: solr_name('resource_type', :facetable)
    config.add_index_field solr_name('file_format', :stored_searchable), link_to_search: solr_name('file_format', :facetable)
    config.add_index_field solr_name('identifier', :stored_searchable), helper_method: :index_field_link, field_name: 'identifier'
    config.add_index_field solr_name('embargo_release_date', :stored_sortable, type: :date), label: 'Embargo release date', helper_method: :human_readable_date
    config.add_index_field solr_name('lease_expiration_date', :stored_sortable, type: :date), label: 'Lease expiration date', helper_method: :human_readable_date

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # Reject the non-label form of controlled vocabular terms from being searchable or indexable
    rejected_fields = Generic.controlled_property_labels.map { |field| field.gsub('_label', '') }
    rejected_fields += %w[rights_statement resource_type license language]

    # Add all fields as searchable, reject the non-searchable fields
    Document.document_properties.reject { |attr| rejected_fields.include? attr }.each do |prop|
      # Skip if this property isn't indexed
      next if Document.properties[prop].behaviors.nil? || Generic.properties.key?(prop)

      # Add property as searchable all fields box and individually
      if Document.properties[prop].behaviors.include?(:stored_searchable)
        config.add_show_field solr_name(prop, :stored_searchable)
        config.add_search_field(prop) do |field|
          solr_name = solr_name(prop, :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end
      end

      # Add property as facetable
      config.add_facet_field solr_name(prop, :facetable), label: I18n.translate("simple_form.labels.defaults.#{prop}"), limit: 5 if Document.properties[prop].behaviors.include?(:facetable)
    end
    Generic.generic_properties.reject { |attr| rejected_fields.include? attr }.each do |prop|
      # Skip if this property isn't indexed
      next if Generic.properties[prop].behaviors.nil?

      # Add property as searchable all fields box and individually
      if Generic.properties[prop].behaviors.include?(:stored_searchable)
        config.add_show_field solr_name(prop, :stored_searchable)
        config.add_search_field(prop) do |field|
          solr_name = solr_name(prop, :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end
      end

      # Add property as facetable
      config.add_facet_field solr_name(prop, :facetable), label: I18n.translate("simple_form.labels.defaults.#{prop}"), limit: 5 if Generic.properties[prop].behaviors.include?(:facetable)
    end
    Image.image_properties.reject { |attr| rejected_fields.include? attr }.each do |prop|
      # Skip if this property isn't indexed
      next if Image.properties[prop].behaviors.nil? || Generic.properties.key?(prop)

      # Add property as searchable all fields box and individually
      if Image.properties[prop].behaviors.include?(:stored_searchable)
        config.add_show_field solr_name(prop, :stored_searchable)
        config.add_search_field(prop) do |field|
          solr_name = solr_name(prop, :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end
      end

      # Add property as facetable
      config.add_facet_field solr_name(prop, :facetable), label: I18n.translate("simple_form.labels.defaults.#{prop}"), limit: 5 if Image.properties[prop].behaviors.include?(:facetable)
    end
    Video.video_properties.reject { |attr| rejected_fields.include? attr }.each do |prop|
      # Skip if this property isn't indexed
      next if Video.properties[prop].behaviors.nil? || Generic.properties.key?(prop)

      # Add property as searchable all fields box and individually
      if Video.properties[prop].behaviors.include?(:stored_searchable)
        config.add_show_field solr_name(prop, :stored_searchable)
        config.add_search_field(prop) do |field|
          solr_name = solr_name(prop, :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end
      end

      # Add property as facetable
      config.add_facet_field solr_name(prop, :facetable), label: I18n.translate("simple_form.labels.defaults.#{prop}"), limit: 5 if Video.properties[prop].behaviors.include?(:facetable)
    end
    Generic.controlled_property_labels.each do |prop|
      label = prop.gsub('_label', '')

      # Skip if this property isn't indexed
      next if Generic.properties[label].behaviors.nil?

      # Add property as searchable all fields box and individually
      if Generic.properties[label].behaviors.include?(:stored_searchable)
        config.add_show_field solr_name(prop, :stored_searchable)
        config.add_search_field(prop) do |field|
          solr_name = solr_name(prop, :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end
      end

      # Add property as facetable
      config.add_facet_field solr_name(prop, :facetable), label: I18n.translate("simple_form.labels.defaults.#{label}"), limit: 5 if Generic.properties[label].behaviors.include?(:facetable)
    end
    config.add_show_field solr_name('language_label', :stored_searchable)
    config.add_show_field solr_name('type_label', :stored_searchable)
    config.add_show_field solr_name('rights_statement_label', :stored_searchable)

    config.add_facet_field solr_name('language_label', :facetable), label: I18n.translate('simple_form.labels.defaults.language'), limit: 5
    config.add_facet_field solr_name('type_label', :facetable), label: I18n.translate('simple_form.labels.defaults.type'), limit: 5
    config.add_facet_field solr_name('rights_statement_label', :facetable), label: I18n.translate('simple_form.labels.defaults.rights_statement'), limit: 5
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
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(' ')
      title_name = solr_name('title', :stored_searchable)
      field.solr_parameters = {
        qf: "#{all_names} #{title_name} file_format_tesim all_text_timv",
        pf: title_name.to_s
      }
    end

    # 'sort results by' select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: 'relevance'
    config.add_sort_field "#{uploaded_field} desc", label: 'date uploaded \u25BC'
    config.add_sort_field "#{uploaded_field} asc", label: 'date uploaded \u25B2'
    config.add_sort_field "#{modified_field} desc", label: 'date modified \u25BC'
    config.add_sort_field "#{modified_field} asc", label: 'date modified \u25B2'

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
