# frozen_string_literal:true

require 'iiif_manifest'

module OregonDigital
  # JP2Presenter wraps a single JP2 derivative as if it were a fileset of its
  # own, strictly for the IIIF manifest / viewer.  This is adapted from
  # Hyrax::DisplaysImage.
  class JP2Presenter
    delegate :id, to: :file_set
    attr_reader :readable, :file_set, :jp2_path, :label, :request

    def initialize(file_set, jp2_path, label, current_ability, request)
      @readable = current_ability.can?(:read, file_set)
      @file_set = file_set
      @jp2_path = jp2_path
      @label = label
      @request = request
    end

    # Creates a display image for IIIFManifest
    #
    # @return [IIIFManifest::V3::DisplayContent] the display image required by the manifest builder.
    def display_content
      return nil unless readable

      # I have no idea why we have to specify height here; IIIF doesn't require
      # it.  But this is how the Hyrax code seems to work, sooo....
      IIIFManifest::V3::DisplayContent.new(default_content_path,
                                     type: 'Image',
                                     format: 'image/jpeg',
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

    # Calculates the IIIF ID for this JP2 by faking a fileset (again) becuase
    # the Hyrax derivative path magic doesn't actually give us any easy way to
    # just ask for the relative path to a derivative.
    def iiif_id
      fake_fs = OpenStruct.new(id: 'id')
      fake_ds = OregonDigital::FileSetDerivativesService.new(fake_fs)

      # This should end up looking very much like "file:///data/tmp/shared/derivatives/"
      base_path = fake_ds.derivative_url('jp2').sub('id-jp2.jp2', '')

      # ...which should make *this* look like "qb%wF98%2Fmf%2F44%2F9-jp2-0005.jp2"
      jp2_path.sub(base_path, '').gsub('/', '%2F')
    end

    # Calculates the base URL for IIIF requests against this JP2
    def iiif_url
      [ENV.fetch('IIIF_SERVER_BASE_URL', request.base_url), iiif_id].join('/')
    end

    def default_content_path
      [iiif_url, 'full', '640,', '0', 'default.jpg'].join('/')
    end

    def iiif_endpoint
      IIIFManifest::IIIFEndpoint.new(iiif_url, profile: Hyrax.config.iiif_image_compliance_level_uri)
    end
  end
end
