# Generated via
#  `rails generate hyrax:work Generic`
module Hyrax
  # Generated controller for Generic
  class GenericsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Generic

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericPresenter
  end
end
