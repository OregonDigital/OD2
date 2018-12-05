# frozen_string_literal:true

module Hyrax
  class ImagePresenter < Hyrax::GenericPresenter
    delegate(*OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym), to: :solr_document)
  end
end
