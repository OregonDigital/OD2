# frozen_string_literal:true

require 'iiif_manifest'

module OregonDigital
  # MP3Presenter wraps a single MP3 derivative as if it were a fileset of its
  # own, strictly for the IIIF manifest / viewer.  This is adapted from
  # Hyrax::DisplaysImage.
  class MP3Presenter
    delegate :id, to: :file_set
    attr_reader :readable, :file_set, :mp3_path, :label, :request

    def initialize(file_set, mp3_path, label, current_ability, request)
      @readable = current_ability.can?(:read, file_set)
      @file_set = file_set
      @mp3_path = mp3_path
      @label = label
      @request = request
    end

    # Creates a display image for IIIFManifest
    #
    # @return [IIIFManifest::V3::DisplayContent] the display image required by the manifest builder.
    def display_content
      return nil unless readable

      IIIFManifest::V3::DisplayContent.new(default_content_path,
                                     type: 'Audio',
                                     format: 'audio/mp3',
                                     duration: self.duration)
    end

    # Returns the derivative file's label - this appears to be used by Hyrax
    # and/or IIIFManifest to present a label for a presenter's image
    def to_s
      label
    end

    private

    def duration
      dur = @file_set.duration.first.split(":").map(&:to_i)
      (dur.first * 3600) + (dur.second * 60) + dur.third + 1
    end

    # The path to the derivative download
    def default_content_path
      request.base_url + Hyrax::Engine.routes.url_helpers.download_path(file_set, file: 'mp3')
    end
  end
end