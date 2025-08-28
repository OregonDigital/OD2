# frozen_string_literal:true

module Hyrax
  # Generated controller for Image
  class ImagesController < ApplicationController
    load_and_authorize_resource except: [:manifest]

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::PresentsDataSources
    include OregonDigital::DownloadControllerBehavior
    include OregonDigital::WorksControllerBehavior
    include OregonDigital::WorkRelationPaginationBehavior

    # Redirect for Bot Detection
    before_action do |controller|
      BotDetectionController.bot_detection_enforce_filter(controller)
    end

    self.curation_concern_type = ::Image

    # Remove list view from child/sibling renders
    configure_blacklight do |config|
      config.view.list.if = false
    end

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter
  end
end
