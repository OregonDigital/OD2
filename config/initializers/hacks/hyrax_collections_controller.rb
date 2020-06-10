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
    process_facets if collection.facet_configurable?
    @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
    # we don't have to reindex the full graph when updating collection
    @collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
    if @collection.update(collection_params.except(:members))
      after_update
    else
      after_update_error
    end
  end

  # Override after create method to redirect users back to where they created the collection from
  def after_create
    form
    set_default_permissions
    # if we are creating the new collection as a subcollection (via the nested collections controller),
    # we pass the parent_id through a hidden field in the form and link the two after the create.
    link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
    respond_to do |format|
      ActiveFedora::SolrService.instance.conn.commit
      format.html do
        case URI(request.referer).path.split('/')[1]
        when 'dashboard'
          redirect_to edit_dashboard_collection_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success')
        else
          redirect_back fallback_location: '/'
        end
      end
      format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
    end
  end

  # Override after update method to redirect users back to where they updated the collection from
  def after_update
    respond_to do |format|
      format.html do
        case URI(request.referer).path.split('/')[1]
          when 'dashboard'
            redirect_to update_referer, notice: t('hyrax.dashboard.my.action.collection_update_success')
          else
            redirect_back fallback_location: '/'
          end
        end
      format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
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
