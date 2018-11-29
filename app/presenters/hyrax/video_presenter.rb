# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  class VideoPresenter < Hyrax::GenericPresenter
    delegate *OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym), to: :solr_document 
  end
end
