# frozen_string_literal:true

module OregonDigital
  # Behavior for each work type controller
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    included do
      prepend_before_action :redirect_mismatched_work, only: [:show]

      before_action only: :show do |controller|
        BotDetectionController.bot_detection_enforce_filter(controller)
      end
      
      def redirect_mismatched_work
        curation_concern = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: params[:id])
        redirect_to(main_app.polymorphic_path(curation_concern), status: :moved_permanently) and return if curation_concern.internal_resource.safe_constantize != _curation_concern_type
      end
    end

    # We can use Hyrax::WorksControllerBehavior definition and add on additional params we want
    def attributes_for_actor
      attributes = super
      oembed_urls = params.fetch(:oembed_urls, [])
      attributes[:oembed_urls] = oembed_urls

      attributes
    end

    def create
      # Resetting :member_of_collection_ids to nil if we were given an empty string
      # This helps failed form submissions to return to the form and display errors
      params[hash_key_for_curation_concern][:member_of_collection_ids] = nil if params[hash_key_for_curation_concern][:member_of_collection_ids].empty?
      set_permissions_to_work
      set_content_alert
      super
    end

    # MODIFY: Add in a special method to help on updating the permissions
    def update
      set_permissions_to_work
      set_content_alert
      super
    end

    private

    # METHOD: Manually ingest in the group/user permission on work form
    # rubocop:disable Metrics/AbcSize
    def set_permissions_to_work
      # VAR: Add in an array for permission storage
      permission_arr = []

      # FIND: Find the permission attributes & convert into a hash
      permission_vals = params[hash_key_for_curation_concern][:permissions_attributes].to_unsafe_h unless params[hash_key_for_curation_concern][:permissions_attributes].blank?

      # LOOP: Loop through each hash & store all the permission into the var
      permission_vals.map { |val| permission_arr << val[1] } unless permission_vals.blank?

      # ASSIGN: Get it into the curation_concern with the value
      curation_concern.permissions_attributes = (permission_arr) unless permission_arr.blank?
    end
    # rubocop:enable Metrics/AbcSize

    # METHOD: Check for mask_content not being check
    def set_content_alert
      curation_concern.content_alert = nil if params[hash_key_for_curation_concern][:mask_content].all?(&:blank?)
    end

    def after_update_response
      OregonDigital::PermissionChangeEventJob.perform_later(curation_concern, current_user) if permissions_changed?
      super
    end

    # Override from hyrax to add in a different message depending on if the work is tombstoned or under review
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def render_unavailable
      @tombstoned = (unavailable_presenter.workflow.state == 'tombstoned')
      message = @tombstoned ? I18n.t('hyrax.workflow.tombstoned') : I18n.t('hyrax.workflow.unauthorized')
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
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
