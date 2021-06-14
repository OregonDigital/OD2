# frozen_string_literal:true

module OregonDigital
  # Controller for explore collections interface
  class ExploreCollectionsController < ApplicationController
    include Blacklight::SearchContext
    include Blacklight::SearchHelper
    include Blacklight::AccessControls::Catalog

    attr_accessor :tab, :builder

    def all;
      @tab = TABS[:all]
      @builder = OregonDigital::NonUserCollectionsSearchBuilder.new(self).rows(1000)
      render :index
    end
    def osu;
      @tab = TABS[:osu]
      @builder = OregonDigital::OsuCollectionsSearchBuilder.new(self).rows(1000)
      render :index
    end
    def uo;
      @tab = TABS[:uo]
      @builder = OregonDigital::UoCollectionsSearchBuilder.new(self).rows(1000)
      render :index
    end
    def my;
      @tab = TABS[:my]
      @builder = OregonDigital::MyCollectionsSearchBuilder.new(self).rows(1000)
      render :index
    end

    # Return all collections
    def collections
      response = repository.search(@builder)
      response.documents
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    def total_viewable_items(id)
      Hyrax::SolrService.query("member_of_collection_ids_ssim:#{id}").length
    end

    def osu_items(id)
      Hyrax::SolrService.query("member_of_collection_ids_ssim:#{id} AND visibility_ssi:osu")
    end

    def uo_items(id)
      Hyrax::SolrService.query("member_of_collection_ids_ssim:#{id} AND visibility_ssi:uo")
    end

    def osu_restricted?(id)
      !osu_items(id).empty? && current_ability.cannot?(:show, osu_items(id), visibility: 'osu')
    end

    def uo_restricted?(id)
      !uo_items(id).empty? && current_ability.cannot?(:show, uo_items(id), visibility: 'uo')
    end

    def institution_restricted?(id)
      osu_restricted?(id) || uo_restricted?(id)
    end

    TABS = {
      all: 'all',
      osu: 'osu',
      uo: 'uo',
      my: 'my'
    }.freeze
  end
end
