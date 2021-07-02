# frozen_string_literal:true

module Hyrax
  # Generated controller for Generic
  class GenericsController < ApplicationController
    load_and_authorize_resource except: [:manifest]

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::DownloadControllerBehavior
    prepend OregonDigital::WorksControllerBehavior
    self.curation_concern_type = ::Generic

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    # Include 'catalog' in the search path for views, while prefering
    # our local paths. Thus we are unable to just override `self.local_prefixes`
    def _prefixes
      @_prefixes ||= super + ['catalog']
    end

    def create
      # Resetting :member_of_collection_ids to nil if we were given an empty string
      # This helps failed form submissions to return to the form and display errors
      params[hash_key_for_curation_concern][:member_of_collection_ids] = nil if params[hash_key_for_curation_concern][:member_of_collection_ids].empty?
      super
    end

    # OVERRIDE FROM HYRAX TO: Setup parent, child, and sibling BlackLight search results
    # Finds a solr document matching the id and sets @presenter
    # @raise CanCan::AccessDenied if the document is not found or the user doesn't have access to it.
    def show
      blacklight_config.per_page = [4]
      parent_results
      sibling_results
      child_results
      @search_builder_class = Hyrax::WorkSearchBuilder
      super
    end

    def search_builder
      work ||= ::SolrDocument.find(params['id'])
      search_builder_class == Hyrax::WorkSearchBuilder ? search_builder_class.new(self) : search_builder_class.new(self, work: work)
    end

    def parent_results
      @search_builder_class = OregonDigital::ParentsOfWorkSearchBuilder
      params[:page] = params[:parent_page]
      (@parent_response, @parent_doc_list) = search_results(params)
    end
    #TODO: Implement and set OregonDigital::SiblingsOfWorkSearchBuilder
    def sibling_results
      @search_builder_class = OregonDigital::SiblingsOfWorkSearchBuilder
      params[:page] = params[:sibling_page]
      (@sibling_response, @sibling_doc_list) = search_results(params)
    end
    #TODO: Implement and set OregonDigital::ChildrenOfWorkSearchBuilder
    def child_results
      @search_builder_class = OregonDigital::ChildrenOfWorkSearchBuilder
      params[:page] = params[:child_page]
      (@child_response, @child_doc_list) = search_results(params)
    end

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericPresenter
  end
end
