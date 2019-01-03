# frozen_string_literal:true

module Hyrax
  # Display config for video object
  class VideoPresenter < Hyrax::GenericPresenter
    delegate(*OregonDigital::VideoMetadata::PROPERTIES.map(&:to_sym), to: :solr_document)
  end
end
