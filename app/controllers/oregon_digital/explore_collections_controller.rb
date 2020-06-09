# frozen_string_literal:true

module OregonDigital
  # Controller for explore collections interface
  class ExploreCollectionsController < ApplicationController
    include Blacklight::SearchContext
    include Blacklight::SearchHelper
    include Blacklight::AccessControls::Catalog

    def index; end

    def edit
      @collection = ::Collection.find(params[:id])
    end

    # Return all collections
    def collections
      builder = OregonDigital::NonUserCollectionsSearchBuilder.new(self)
      response = repository.search(builder)
      response.documents
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    # Return OSU collections
    def osu_collections
      builder = OregonDigital::NonUserCollectionsSearchBuilder.new(self)
      response = repository.search(builder)
      response.documents
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    # Return UO collections
    def uo_collections
      builder = OregonDigital::NonUserCollectionsSearchBuilder.new(self)
      response = repository.search(builder)
      response.documents
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    # Return My collections
    def my_collections
      builder = OregonDigital::MyCollectionsSearchBuilder.new(self)
      response = repository.search(builder)
      response.documents
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    def total_viewable_items(id)
      ActiveFedora::Base.where("member_of_collection_ids_ssim:#{id}").accessible_by(current_ability).count
    end

    TABS = {
      all: 'all',
      osu: 'osu',
      uo: 'uo',
      my: 'my'
    }.freeze
  end
end
