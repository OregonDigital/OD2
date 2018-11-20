# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  class VideoPresenter < Hyrax::WorkShowPresenter
    delegate :height, :width, to: :solr_document
  end
end
