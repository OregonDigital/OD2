# frozen_string_literal:true

Rails.application.config.to_prepare do
  # Always allow users to download/view thumbnails
  Hyrax::DownloadsController.class_eval do

    private

    # Customize the :read ability in your Ability class, or override this method.
    # Hydra::Ability#download_permissions can't be used in this case because it assumes
    # that files are in a LDP basic container, and thus, included in the asset's uri.
    def authorize_download!
      # Add a short circuit if we're downloading the thumbnail
      return true if params[:file] == 'thumbnail'

      authorize! :download, params[asset_param_key]
    rescue CanCan::AccessDenied
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
      send_file unauthorized_image, status: :unauthorized
    end
  end
end