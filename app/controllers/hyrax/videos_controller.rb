# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated controller for Video
  class VideosController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Video

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::VideoPresenter
  end
end
