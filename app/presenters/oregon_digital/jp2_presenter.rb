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
    # @return [IIIFManifest::DisplayImage] the display image required by the manifest builder.
    def display_content
      return nil unless readable

      # I have no idea why we have to specify height here; IIIF doesn't require
      # it.  But this is how the Hyrax code seems to work, sooo....
      IIIFManifest::V3::DisplayContent.new(default_image_path,
                                     type: 'Video',
                                     format: 'video/mp4',
                                     width: 426,
                                     height: 240,
                                     duration: 46)
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
      ['test.library.oregonstate.edu:3000', iiif_id].join('/')
    end

    def default_image_path
      [iiif_url, 'full', '640,', '0', 'default.jpg'].join('/')
      'http://test.library.oregonstate.edu:3000/downloads/kk91fk52?file=mp4'
    end

    def iiif_endpoint
      IIIFManifest::IIIFEndpoint.new(iiif_url, profile: Hyrax.config.iiif_image_compliance_level_uri)
    end
  end
end
