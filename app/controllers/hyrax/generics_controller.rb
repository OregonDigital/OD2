# frozen_string_literal:true

module Hyrax
  # Generated controller for Generic
  class GenericsController < ApplicationController
    load_and_authorize_resource except: [:manifest]

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::DownloadControllerBehavior
    prepend OregonDigital::WorksControllerBehavior
    self.curation_concern_type = ::Generic

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericPresenter

    def add_oembed_error(error)
      errors = OembedError.find_or_create_by(document_id: params['id'])
      errors.oembed_errors << error unless errors.oembed_errors.include? error
      errors.save
    end
  end
end
