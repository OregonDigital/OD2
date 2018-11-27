# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyrax::WorkShowPresenter
    delegate *OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym), to: :solr_document 
    delegate *OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym), to: :solr_document 
  end
end
