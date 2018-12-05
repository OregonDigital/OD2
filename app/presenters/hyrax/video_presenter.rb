# frozen_string_literal:true

module Hyrax
  class VideoPresenter < Hyrax::GenericPresenter
    delegate(*OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym), to: :solr_document)
  end
end
