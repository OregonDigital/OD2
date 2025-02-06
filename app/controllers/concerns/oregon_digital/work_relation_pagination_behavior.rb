# frozen_string_literal: true

module OregonDigital
  # Behavior for displaying relationships with pagination
  module WorkRelationPaginationBehavior
    COUNT = 4
    # Include 'catalog' in the search path for views, while prefering
    # our local paths. Thus we are unable to just override `self.local_prefixes`
    def _prefixes
      @_prefixes ||= super + ['catalog']
    end

    # OVERRIDE FROM HYRAX TO: Setup parent, child, and sibling BlackLight search results
    # Finds a solr document matching the id and sets @presenter
    # @raise CanCan::AccessDenied if the document is not found or the user doesn't have access to it.
    def show
      blacklight_config.per_page = [COUNT]
      parent_results
      sibling_results
      child_results
      ordered_child_results
      @search_builder_class = Hyrax::WorkSearchBuilder
      super
    end

    # Pass work to relationship search builders
    def search_builder
      search_builder_class == Hyrax::WorkSearchBuilder ? search_builder_class.new(self) : search_builder_class.new(self, work: work)
    end

    def work
      @work ||= begin
        doc = ::SolrDocument.find(params['id'])
        Hyrax::SolrDocument::OrderedMembers.decorate(doc)
      end
    end

    # Get all parent documents
    def parent_results
      @search_builder_class = OregonDigital::ParentsOfWorkSearchBuilder
      params[:page] = params[:parent_page]
      (@parent_response, @parent_doc_list) = search_results(params)
    end

    # Get all sibling documents
    def sibling_results
      @search_builder_class = OregonDigital::SiblingsOfWorkSearchBuilder
      params[:page] = params[:sibling_page]
      (@sibling_response, @sibling_doc_list) = search_results(params)
    end

    # get all child works for response
    def child_results
      @search_builder_class = OregonDigital::ChildrenOfWorkSearchBuilder
      params[:page] = params[:child_page]
      (@child_response,) = search_results(params)
    end

    # hacky method for getting one page of child docs in order
    def ordered_child_results
      @child_doc_list = []
      return unless @child_response['response']['numFound'].positive?

      @search_builder_class = OregonDigital::OrderedChildrenOfWorkSearchBuilder
      (_, @child_doc_list) = search_results(params)
      @child_doc_list = sort_by_ordered(@child_doc_list, start(params[:child_page]))
    end

    def sort_by_ordered(doc_list, start_ind)
      ordered_docs = []
      work.ordered_member_ids.slice(start_ind, COUNT).each do |id|
        ordered_docs << doc_list.find { |x| x['id'] == id }
      end
      ordered_docs.compact
    end

    def start(page)
      return 0 if page.nil?

      (page.to_i - 1) * COUNT
    end
  end
end
