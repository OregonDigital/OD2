# frozen_string_literal:true

require 'iiif_manifest'

module OregonDigital
  # JP2Presenter wraps a single JP2 derivative as if it were a fileset of its
  # own, strictly for the IIIF manifest / viewer.  This is adapted from
  # Hyrax::DisplaysImage.
  class JP2Presenter
    delegate :id, to: :file_set
    attr_reader :readable, :file_set, :iiif_id, :label, :request

    def initialize(file_set, iiif_id, label, current_ability, request)
      @readable = current_ability.can?(:read, file_set)
      @file_set = file_set
      @iiif_id = iiif_id
      @label = label
      @request = request
    end

    # Creates a display image for IIIFManifest
    #
    # @return [IIIFManifest::DisplayImage] the display image required by the manifest builder.
    def display_image
      return nil unless readable

      # I have no idea why we have to specify height here; IIIF doesn't require
      # it.  But this is how the Hyrax code seems to work, sooo....
      IIIFManifest::DisplayImage.new(default_image_path,
                                     width: 640,
                                     height: 480,
                                     iiif_endpoint: iiif_endpoint)
    end

    # Returns the derivative file's label - this appears to be used by Hyrax
    # and/or IIIFManifest to present a label for a presenter's image
    def to_s
      label
    end

    private

    # Calculates the base URL for IIIF requests against this JP2
    def iiif_url
      [ENV.fetch('IIIF_SERVER_BASE_URL', request.base_url), CGI.escape(iiif_id)].join('/')
    end

    def default_image_path
      [iiif_url, 'full', '640,', '0', 'default.jpg'].join('/')
    end

    def iiif_endpoint
      IIIFManifest::IIIFEndpoint.new(iiif_url, profile: Hyrax.config.iiif_image_compliance_level_uri)
    end
  end
end
