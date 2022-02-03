# frozen_string_literal:true

module Hyrax
  # Generated controller for Generic
  class GenericsController < ApplicationController
    load_and_authorize_resource except: [:manifest]

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::PresentsDataSources
    include OregonDigital::DownloadControllerBehavior
    prepend OregonDigital::WorksControllerBehavior
    include OregonDigital::WorkRelationPaginationBehavior
    self.curation_concern_type = ::Generic

    # Remove list view from child/sibling renders
    configure_blacklight do |config|
      config.view.list.if = false
    end

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericPresenter
  end
end
