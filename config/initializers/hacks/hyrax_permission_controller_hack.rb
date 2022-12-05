# frozen_string_literal: true

Rails.application.config.to_prepare do
  Hyrax::PermissionsController.class_eval do
    def copy_access
      authorize! :edit, curation_concern
      # OVERRIDE FROM HYRAX to forcefully inherit permissions before copying visibility
      # copy permissions
      InheritPermissionsJob.perform_now(curation_concern)
      # copy visibility
      VisibilityCopyJob.perform_later(curation_concern)

      redirect_to [main_app, curation_concern], notice: I18n.t("hyrax.upload.change_access_flash_message")
    end
  end
end
