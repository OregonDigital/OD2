# frozen_string_literal:true

# Controller for homepage
class Hyrax::HomepageController < ApplicationController
  # Adds Hydra behaviors into the application controller
  include Blacklight::SearchContext
  include Blacklight::AccessControls::Catalog

  class_attribute :presenter_class
  self.presenter_class = Hyrax::HomepagePresenter
  layout 'homepage'
  helper Hyrax::ContentBlockHelper

  def index
    @presenter = presenter_class.new(current_ability, collections)
    @featured_researcher = ContentBlock.for(:researcher)
    @marketing_text = ContentBlock.for(:marketing)
    @featured_work_list = FeaturedWorkList.new
    @announcement_text = ContentBlock.for(:announcement)
    recent
  end

  private

  # OVERRIDE FROM HYRAX to increase number of collections rows
  # Return 8 collections
  def collections(rows: 8)
    # TODO: set CollectionSearchBuilder to retrieve collections from a curated list, instead of newest collections
    Hyrax::CollectionsService.new(self).search_results do |builder|
      builder.rows(rows)
      builder.merge(sort: sort_field)
    end
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    []
  end

  def recent
    # OVERRIDE FROM HYRAX to increase number of recent document rows
    # grab any recent documents
    (_, @recent_documents) = search_service.search_results do |builder|
      builder.rows(6)
      builder.merge(sort: sort_field)
    end
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    @recent_documents = []
  end

  def search_service
    Hyrax::SearchService.new(config: blacklight_config, user_params: { q: '' }, scope: self, search_builder_class: OregonDigital::NonUserCollectionsSearchBuilder)
  end

  def sort_field
    'system_create_dtsi desc'
  end
end
