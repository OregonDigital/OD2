# frozen_string_literal: true

module OregonDigital
  # Behavior for displaying relationships with pagination
  module WorkRelationPaginationBehavior
    # Include 'catalog' in the search path for views, while prefering
    # our local paths. Thus we are unable to just override `self.local_prefixes`
    def _prefixes
      @_prefixes ||= super + ['catalog']
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

    # Pass work to relationship search builders
    def search_builder
      work ||= ::SolrDocument.find(params['id'])
      search_builder_class == Hyrax::WorkSearchBuilder ? search_builder_class.new(self) : search_builder_class.new(self, work: work)
    end

    # Get all parent documents
    def parent_results
      @search_builder_class = OregonDigital::ParentsOfWorkSearchBuilder
      params[:page] = params[:parent_page]
      (@parent_response, @parent_doc_list) = search_service.search_results do |builder|
        search_builder
      end
    end

    # Get all sibling documents
    def sibling_results
      @search_builder_class = OregonDigital::SiblingsOfWorkSearchBuilder
      params[:page] = params[:sibling_page]
      (@sibling_response, @sibling_doc_list) = search_service.search_results do |builder|
        search_builder
      end
    end

    # get all child documents
    def child_results
      @search_builder_class = OregonDigital::ChildrenOfWorkSearchBuilder
      params[:page] = params[:child_page]
      (@child_response, @child_doc_list) = search_service.search_results do |builder|
        search_builder
      end
    end
  end
end
