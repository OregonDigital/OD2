# frozen_string_literal:true

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
end