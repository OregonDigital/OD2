# frozen_string_literal:true

require 'iiif_manifest'

module OregonDigital
  # MP4Presenter wraps a single MP4 derivative as if it were a fileset of its
  # own, strictly for the IIIF manifest / viewer.  This is adapted from
  # Hyrax::DisplaysImage.
  class MP4Presenter
    delegate :id, to: :file_set
    attr_reader :readable, :file_set, :mp4_path, :label, :request

    def initialize(file_set, mp4_path, label, current_ability, request)
      @readable = current_ability.can?(:read, file_set)
      @file_set = file_set
      @mp4_path = mp4_path
      @label = label
      @request = request
    end

    # Creates a display content for IIIFManifest
    #
    # @return [IIIFManifest::V3::DisplayContent] the display content required by the manifest builder.
    def display_content
      return nil unless readable

      IIIFManifest::V3::DisplayContent.new(default_content_path,
                                      type: 'Video',
                                      format: 'video/mp4',
                                      width: file_set.width.first,
                                      height: file_set.height.first,
                                      duration: (file_set.duration.first.to_f / 1000).ceil)
    end

    # Returns the derivative file's label - this appears to be used by Hyrax
    # and/or IIIFManifest to present a label for a presenter's image
    def to_s
      label
    end

    private

    # The path to the derivative download
    def default_content_path
      request.base_url + Hyrax::Engine.routes.url_helpers.download_path(file_set, file: 'mp4')
    end
  end
end
