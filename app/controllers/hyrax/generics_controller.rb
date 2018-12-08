# frozen_string_literal:true

module Hyrax
  # Generated controller for Generic
  class GenericsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Generic

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericPresenter

    def add_oembed_error(error)
      errors = OembedError.find_or_create_by(document_id: params['id'])
      errors.oembed_errors << error unless errors.oembed_errors.include? error
      errors.save
    end
  end
end
