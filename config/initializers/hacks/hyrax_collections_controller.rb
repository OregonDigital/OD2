# frozen_string_literal:true

Rails.application.config.to_prepare do
  require Hyrax::Engine.root.join('lib', 'hyrax', 'search_state.rb')
  Hyrax::CollectionsController.class_eval do
    self.presenter_class = OregonDigital::CollectionPresenter
  end

  Hyrax::Dashboard::CollectionsController.class_eval do
    self.form_class = OregonDigital::Forms::CollectionForm
    self.presenter_class = OregonDigital::CollectionPresenter


      # Renders a JSON response with a list of files in this collection
      # This is used by the edit form to populate the thumbnail_id dropdown
      def files
        work_id = params[:q]
        file_set_ids = Hyrax::SolrService.query("member_of_collection_ids_ssim:#{collection.id} AND id:#{work_id}*", rows: 100, fl: 'file_set_ids_ssim').flat_map{ |sd| sd['file_set_ids_ssim'] }
        result = file_set_ids.map do |id|
          label = SolrDocument.find(id).to_s
          { id: id, text: label }
        end
        render json: result
      end

    # Override update to add facet processing
    def update
      unless params[:update_collection].nil?
        process_banner_input
        process_logo_input
      end

      process_member_changes
      process_facets if collection.facet_configurable? && !params[:facet_configuration].blank?
      process_representative_images
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
      create_default_representative_images
      respond_to do |format|
        Hyrax::SolrService.instance.conn.commit
        format.html do
          case URI(request.referer).path.split('/')[1]
          when 'dashboard'
            redirect_to edit_dashboard_collection_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success')
          when 'explore_collections'
            redirect_to Rails.application.routes.url_helpers.my_explore_collections_path
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
            when 'explore_collections'
              alert_message = messages_from_params
              redirect_to Rails.application.routes.url_helpers.my_explore_collections_path, alert: alert_message
            else
              redirect_back fallback_location: '/'
            end
          end
        format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
      end
    end

    # Override after destroy method to redirect users back to where they destroyed the collection from
    def after_destroy(_id)
      # leaving id to avoid changing the method's parameters prior to release
      respond_to do |format|
        format.html do
          case URI(request.referer).path.split('/')[1]
            when 'dashboard'
              redirect_to my_collections_path,
                          notice: t('hyrax.dashboard.my.action.collection_delete_success')
            else
              redirect_back fallback_location: '/'
            end
        end
        format.json { head :no_content, location: my_collections_path }
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

    def create_default_representative_images
      repr_ids = params[:representative_ids] || []
      form.select_files.uniq { |f| FileSet.find(f[1]).parent.id }.to_a[repr_ids.reject(&:blank?).count..3].each_with_index do |val, index|
        CollectionRepresentative.create({ collection_id: collection.id, fileset_id: val[1], order: index })
      end
    end

    def process_representative_images
      CollectionRepresentative.where(collection_id: collection.id)&.delete_all
      params[:representative_ids][0..3].each_with_index do |fs_id, index|
        CollectionRepresentative.create({ collection_id: collection.id, fileset_id: fs_id, order: index })
      end unless params[:representative_ids].blank?

      # Skip default images if we already made all 4 images
      return if !params[:representative_ids].nil? && params[:representative_ids].count >= 4
      # Fill unset images with default images to maintain 4 thumbnails
      create_default_representative_images
    end

    # Generate alert messages depending on hidden form data
    def messages_from_params
      return t('oregon_digital.explore_collections.messages.shared', collection_title: collection.title.first) if params['sharing']
      return t('oregon_digital.explore_collections.messages.unshared', collection_title: collection.title.first) if params['unsharing']
      nil
    end

    # Override to chunk batch into groups of 5 to cut down on factorial saves.
    # Compact removes nil from array, which gets autofilled by #in_groups_of
    # when chunking the array. i.e [1, 2, 3, 4 ,5].in_groups_of(2) becomes
    # [[1, 2], [3, 4], [5, nil]]
    def add_members_to_collection(collection = nil)
      collection ||= @collection
      batch.in_groups_of(5).each do |group|
        collection.add_member_objects group.compact
      end
    end
  end
end
