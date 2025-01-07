# frozen_string_literal:true

# Controller for homepage
class Hyrax::HomepageController < ApplicationController
  # Adds Hydra behaviors into the application controller
  include Blacklight::SearchContext
  include Blacklight::AccessControls::Catalog

  # The search builder for finding recent documents
  # Override of Blacklight::RequestBuilders
  def search_builder_class
    Hyrax::HomepageSearchBuilder
  end

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
    builder = OregonDigital::NonUserCollectionsSearchBuilder.new(self)
                                                            .rows(rows)
                                                            .merge(sort: sort_field)
    response = search_service.repository.search(builder)
    response.documents
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    []
  end

  def recent
    # OVERRIDE FROM HYRAX to increase number of recent document rows
    # grab any recent documents
    (_, @recent_documents) = search_results(q: '', sort: sort_field, rows: 6)
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    @recent_documents = []
  end

  def sort_field
    'system_create_dtsi desc'
  end
end
