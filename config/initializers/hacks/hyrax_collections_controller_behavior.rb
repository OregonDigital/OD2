# frozen_string_literal:true

Hyrax::CollectionsControllerBehavior.module_eval do
  # Remove :f (facets) from single item search to allow collection to verify user access
  def single_item_search_builder
    single_item_search_builder_class.new(self).with(params.except(:f, :q, :page))
  end

  def show
    @curation_concern ||= ActiveFedora::Base.find(params[:id])
    configured_facets
    presenter
    query_collection_members
  end

  private

    # Point Blacklight searching to collection route
    def search_action_url options = {}
      hyrax.collection_url(options.except(:controller, :action))
    end

    def configured_facets
      @configured_facets ||= []
    end
end
