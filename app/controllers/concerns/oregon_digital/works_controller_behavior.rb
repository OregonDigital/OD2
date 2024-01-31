# frozen_string_literal:true

module OregonDigital
  # Behavior for each work type controller
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    included do
      prepend_before_action :redirect_mismatched_work, only: [:show]

      def redirect_mismatched_work
        curation_concern = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: params[:id])
        redirect_to(main_app.polymorphic_path(curation_concern), status: :moved_permanently) and return if curation_concern.internal_resource.safe_constantize != _curation_concern_type
      end
    end

    # We can use Hyrax::WorksControllerBehavior definition and add on additional params we want
    def attributes_for_actor
      attributes = super
      #oembed_urls = params.fetch(:oembed_urls, [])
      #attributes[:oembed_urls] = oembed_urls

      attributes
    end

    def create
      # Resetting :member_of_collection_ids to nil if we were given an empty string
      # This helps failed form submissions to return to the form and display errors
      params[hash_key_for_curation_concern][:member_of_collection_ids] = nil if params[hash_key_for_curation_concern][:member_of_collection_ids].empty?
      super
    end

    private

    def after_update_response
      OregonDigital::PermissionChangeEventJob.perform_later(curation_concern, current_user) if permissions_changed?
      super
    end
    
    #Override from hyrax to add in a different message depending on if the work is tombstoned or under review
    def render_unavailable
      tombstoned = (unavailable_presenter.workflow.state == 'tombstoned')
      message = tombstoned ? I18n.t('hyrax.workflow.tombstoned') : I18n.t("hyrax.workflow.unauthorized")
      respond_to do |wants|
        wants.html do
          unavailable_presenter
          flash[:notice] = message
          render 'unavailable', status: :unauthorized
        end
        wants.json { render plain: message, status: :unauthorized }
        additional_response_formats(wants)
        wants.ttl { render plain: message, status: :unauthorized }
        wants.jsonld { render plain: message, status: :unauthorized }
        wants.nt { render plain: message, status: :unauthorized }
      end
    end
  end
end
