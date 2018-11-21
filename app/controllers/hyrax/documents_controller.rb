# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  # Generated controller for Document
  class DocumentsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Document

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DocumentPresenter
  end
end
