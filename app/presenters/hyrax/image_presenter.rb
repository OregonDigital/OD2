# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyrax::WorkShowPresenter
    delegate :resource_type, :colour_content, :color_space, :height, :orientation, :photograph_orientation, :resolution, :view, :width, to: :solr_document
  end
end
