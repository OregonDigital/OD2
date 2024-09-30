# frozen_string_literal:true

module OregonDigital
  # Controller for explore collections interface
  class ExploreCollectionsController < ApplicationController
    include BlacklightAdvancedSearch::Controller
    include BlacklightRangeLimit::ControllerOverride
    include Hydra::Catalog
    include Hydra::Controller::ControllerBehavior
    include OregonDigital::BlacklightConfigBehavior

    attr_accessor :tab

    # Add the 'catalog' folder to where views are looked for
    # This allows us to render blacklight/catalog views from the hyrax/admin/workflows folder
    def self.local_prefixes
      super + ['catalog']
    end

    def page_title
      # CONDITION: Add in a ternary case to upcase / titleize depend on value
      @tab_title = (@tab == 'osu' || @tab == 'uo' ? @tab.upcase : @tab.titleize)
      "#{'Empty ' if @document_list.empty?}Search Results | Explore Collections / #{@tab_title}"
    end

    configure_blacklight do |config|
      config.view.gallery.if = false
      config.view.list.if = false
      config.view.table.partials = %i[index]
      config.view.table.icon_class = 'glyphicon-th-list'
      config.view.masonry.partials = %i[metadata]
      config.view.masonry.icon_class = 'fa fa-trello fa-lg'

      config.sort_fields.except! 'score desc, system_create_dtsi desc', 'date_dtsi desc', 'date_dtsi asc', 'system_create_dtsi desc'
      config.sort_fields['title_ssort desc'][:label] = 'Z-A'
      config.sort_fields['title_ssort asc'][:label] = 'A-Z'
    end

    # Each of these routes sets a different tab and builder then has to run #index to setup the blacklight search results
    def all
      @tab = TABS[:all]
      blacklight_config.search_builder_class = OregonDigital::NonUserCollectionsSearchBuilder
      (@response, @document_list) = search_results(params)
      build_breadcrumbs
      render :index
    end

    def osu
      @tab = TABS[:osu]
      blacklight_config.search_builder_class = OregonDigital::OsuCollectionsSearchBuilder
      (@response, @document_list) = search_results(params)
      build_breadcrumbs
      render :index
    end

    def uo
      @tab = TABS[:uo]
      blacklight_config.search_builder_class = OregonDigital::UoCollectionsSearchBuilder
      (@response, @document_list) = search_results(params)
      build_breadcrumbs
      render :index
    end

    def my
      @tab = TABS[:my]
      blacklight_config.search_builder_class = OregonDigital::MyCollectionsSearchBuilder
      (@response, @document_list) = search_results(params)
      build_breadcrumbs
      render :index
    end

    def total_viewable_items(id)
      ActiveFedora::Base.where("member_of_collection_ids_ssim:#{id}").accessible_by(current_ability).count
    end

    def osu_items(id)
      Hyrax::SolrService.query("member_of_collection_ids_ssim:#{id} AND visibility_ssi:osu").map do |hit|
        SolrDocument.find(hit.id)
      end
    end

    def uo_items(id)
      Hyrax::SolrService.query("member_of_collection_ids_ssim:#{id} AND visibility_ssi:uo").map do |hit|
        SolrDocument.find(hit.id)
      end
    end

    def osu_restricted?(id)
      !osu_items(id).empty? && current_ability.cannot?(:show, { any: osu_items(id) }, visibility: 'osu')
    end

    def uo_restricted?(id)
      !uo_items(id).empty? && current_ability.cannot?(:show, { any: uo_items(id) }, visibility: 'uo')
    end

    def institution_restricted?(id)
      osu_restricted?(id) || uo_restricted?(id)
    end

    def build_breadcrumbs
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t("hyrax.controls.explore_#{@tab}"), @tab
    end

    TABS = {
      all: 'all',
      osu: 'osu',
      uo: 'uo',
      my: 'my collections'
    }.freeze
  end
end
