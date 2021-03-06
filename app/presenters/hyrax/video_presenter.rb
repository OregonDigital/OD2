# frozen_string_literal:true

module Hyrax
  # Display config for video object
  class VideoPresenter < Hyrax::GenericPresenter
    delegate(*Video.video_properties.map(&:to_sym), to: :solr_document)
  end
end
