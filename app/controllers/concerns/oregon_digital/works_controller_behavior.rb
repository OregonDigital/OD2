# frozen_string_literal:true

module OregonDigital
  # Behavior for each work type controller
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    included do
      prepend_before_action :redirect_mismatched_work, only: [:show]

      def redirect_mismatched_work
        curation_concern = ActiveFedora::Base.find(params[:id])
        redirect_to(main_app.polymorphic_path(curation_concern), status: :moved_permanently) and return if curation_concern.class != _curation_concern_type
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
      super
    end

    private

    def after_update_response
      OregonDigital::PermissionChangeEventJob.perform_later(curation_concern, current_user) if permissions_changed?
      super
    end
  end
end
