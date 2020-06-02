# frozen_string_literal:true

# Controller for explore collections interface
class ExploreCollectionsController < ApplicationController
  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include Blacklight::AccessControls::Catalog

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
end
