# frozen_string_literal:true

Rails.application.config.to_prepare do
  # Add our file set controller customizations
  Hyrax::FileSetsController.class_eval do

    private

    # Update events stream with permission change message
    def after_update_response
      OregonDigital::PermissionChangeEventJob.perform_later(curation_concern, current_user) if curation_concern.visibility_changed?
      respond_to do |wants|
        wants.html do
          link_to_file = view_context.link_to(curation_concern, [main_app, curation_concern])
          redirect_to [main_app, curation_concern], notice: view_context.t('hyrax.file_sets.asset_updated_flash.message', link_to_file: link_to_file)
        end
        wants.json do
          @presenter = show_presenter.new(curation_concern, current_ability)
          render :show, status: :ok, location: polymorphic_path([main_app, curation_concern])
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def render_unavailable
      s = SolrDocument.find(Hyrax.query_service.find_parents(resource: unavailable_presenter.to_model).first.id)
      tombstoned = (s.workflow_state == 'tombstoned')
      @parent_presenter = "Hyrax::#{s["has_model_ssim"].first}Presenter".constantize.new(Hyrax.query_service.find_parents(resource: unavailable_presenter.to_model).first, current_ability)
      message = tombstoned ? I18n.t('hyrax.workflow.tombstoned') : I18n.t('hyrax.workflow.unauthorized')
      respond_to do |wants|
        wants.html do
          unavailable_presenter
          flash[:notice] = message
          render 'unavailable', status: :unauthorized
        end
        wants.json do
          render plain: message, status: :unauthorized
        end
        additional_response_formats(wants)
        wants.ttl do
          render plain: message, status: :unauthorized
        end
        wants.jsonld do
          render plain: message, status: :unauthorized
        end
        wants.nt do
          render plain: message, status: :unauthorized
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end