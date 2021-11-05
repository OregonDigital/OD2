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

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    def create
      # Resetting :member_of_collection_ids to nil if we were given an empty string
      # This helps failed form submissions to return to the form and display errors
      params[hash_key_for_curation_concern][:member_of_collection_ids] = nil if params[hash_key_for_curation_concern][:member_of_collection_ids].empty?
      super
    end

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericPresenter
  end
end
