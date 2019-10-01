# frozen_string_literal:true

module Hyrax
  # Generated controller for Generic
  class GenericsController < ApplicationController
    load_and_authorize_resource

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::DownloadControllerBehavior
    self.curation_concern_type = ::Generic

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericPresenter

    def document_not_found!
      doc = ::SolrDocument.find(params[:id])
      raise WorkflowAuthorizationException unless current_ability.can?(:read, doc)

      doc
    end

    def add_oembed_error(error)
      errors = OembedError.find_or_create_by(document_id: params['id'])
      errors.oembed_errors << error unless errors.oembed_errors.include? error
      errors.save
    end
  end
end
