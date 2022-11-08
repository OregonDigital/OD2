# frozen_string_literal:true

module OregonDigital
  # Behavior for each work type controller
  module WorksControllerBehavior

    # Send user to 403 page rather than forward with flash message
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |wants|
        wants.json { head :forbidden }
        wants.html { render(file: File.join('public/403.html'), status: 403, layout: false) }
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
