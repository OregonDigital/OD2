# frozen_string_literal:true

module Hyrax
  # Generated controller for Image
  class ImagesController < ApplicationController
    load_and_authorize_resource except: [:manifest]

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::DownloadControllerBehavior
    prepend OregonDigital::WorksControllerBehavior
    self.curation_concern_type = ::Image

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter
  end
end
