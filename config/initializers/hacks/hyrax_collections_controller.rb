# frozen_string_literal:true

require Hyrax::Engine.root.join('lib', 'hyrax', 'search_state.rb')
Hyrax::Dashboard::CollectionsController.class_eval do
  self.form_class = OregonDigital::Forms::CollectionForm
  self.presenter_class = OregonDigital::CollectionPresenter

  # Override update to add facet processing
  def update
    unless params[:update_collection].nil?
      process_banner_input
      process_logo_input
    end

    process_member_changes
    process_facets
    @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
    # we don't have to reindex the full graph when updating collection
    @collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
    if @collection.update(collection_params.except(:members))
      after_update
    else
      after_update_error
    end
  end

  private

  # Turn form params into Facet objects
  def process_facets
    Rack::Utils.parse_nested_query(params[:facet_configuration])['facet'].each_with_index do |id, index|
      facet = Facet.find id
      facet.label = params["facet_label_#{id}"]
      facet.enabled = params["facet_enabled_#{id}"]
      facet.order = index
      facet.save
    end
  end
end
