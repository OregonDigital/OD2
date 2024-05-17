# frozen_string_literal:true

Rails.application.config.to_prepare do
  Hyrax::Dashboard::CollectionMembersController.class_eval do
    # Override after update method to redirect users back to where they updated the collection from
    def after_update
      respond_to do |format|
        format.html do
          case URI(request.referer).path.split('/')[1]
          when 'dashboard'
            redirect_to success_return_path, notice: t('hyrax.dashboard.my.action.collection_update_success')
          else
            redirect_back fallback_location: '/'
          end
        end
        format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
      end
    end

    def update_members
      err_msg = validate
      after_update_error(err_msg) if err_msg.present?
      return if err_msg.present?

      create_default_representative_images
      @collection.try(:reindex_extent=, Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
      begin
        Hyrax::Collections::CollectionMemberService.add_members_by_ids(collection_id: collection_id,
                                                                       new_member_ids: batch_ids,
                                                                       user: current_user)

        after_update
      rescue Hyrax::SingleMembershipError => err
        messages = JSON.parse(err.message)
        if messages.size == batch_ids.size
          after_update_error(messages.uniq.join(', '))
        elsif messages.present?
          flash[:error] = messages.uniq.join(', ')
          after_update
        end
      end
    end

    # When works are added to the collection we want to pad out the list of representative images if there are less than 4
    def create_default_representative_images
      repr_ids = CollectionRepresentative.where(collection_id: @collection.id).map(&:fileset_id) || []

      # We don't need any new images if we already have 4
      return if repr_ids.count >= 4
      new_ids =  Hyrax.query_service.find_many_by_ids(ids: batch_ids[0..3]).map do |work|
        Hyrax.query_service.custom_queries.find_child_filesets(resource: work)[0]
      end.flatten.map(&:id).map(&:to_s)

      all_ids = (repr_ids + new_ids).reject(&:blank?).uniq

      # We should start adding at the end of the existing images
      index = repr_ids.reject(&:blank?).count
      all_ids[index..3].each do |val|
        CollectionRepresentative.create({ collection_id: @collection.id, fileset_id: val, order: index })
        index += 1
      end
    end
  end
end
