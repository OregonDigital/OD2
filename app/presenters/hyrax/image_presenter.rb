# frozen_string_literal:true

module Hyrax
  # Display config for image object
  class ImagePresenter < Hyrax::GenericPresenter
    delegate(*Image.image_properties.map(&:to_sym), to: :solr_document)
  end
end
