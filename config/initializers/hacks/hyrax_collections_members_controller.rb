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

      collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      members = collection.add_member_objects batch_ids
      messages = members.collect { |member| member.errors.full_messages }.flatten
      if messages.size == members.size
        after_update_error(messages.uniq.join(', '))
      elsif messages.present?
        flash[:error] = messages.uniq.join(', ')
        after_update
      else
        members.each { |member| Hyrax.config.callback.run(:after_update_metadata, member, current_user, warn: false) unless member.instance_of? Collection }
        after_update
      end
    end
  end
end
