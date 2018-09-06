# Generated via
#  `rails generate hyrax:work DefaultHyrax`
module Hyrax
  # Generated controller for DefaultHyrax
  class DefaultHyraxesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::DefaultHyrax

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DefaultHyraxPresenter
  end
end
