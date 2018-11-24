module OregonDigital
  class FileSetDerivativesService
    attr_reader :file_set
    delegate :uri, :mime_type, to: :file_set

    # @param file_set [Hyrax::FileSet] At least for this class, it must have #uri and #mime_type
    def initialize(file_set)
      @file_set = file_set
    end

    def valid?
      supported_mime_types.include?(mime_type)
    end

    def create_derivatives(filename)
      case mime_type
      when 'image/tiff' then create_jp2_image_derivatives(filename)
      when 'image/jp2' then create_jp2_image_derivatives(filename)
      else
        create_image_derivatives(filename)
      end
    end

    def cleanup_derivatives
      derivative_path_factory.derivatives_for_reference(file_set).each do |path|
        FileUtils.rm_f(path)
      end
    end

    # The destination_name parameter has to match up with the file parameter
    # passed to the DownloadsController
    def derivative_url(destination_name)
      path = derivative_path_factory.derivative_path_for_reference(file_set, destination_name)
      URI("file://#{path}").to_s
    end

    private

    def supported_mime_types
      file_set.class.image_mime_types
    end

    def create_jp2_image_derivatives(filename)
      Hydra::Derivatives::Jpeg2kImageDerivatives.create(filename,
                                                        outputs: [{ label: :jp2,
                                                                    format: 'jp2',
                                                                    recipe: '-jp2_space sRGB',
                                                                    processor: 'jpeg2k_image',
                                                                    url: derivative_url('jp2') }])
    end
    def create_image_derivatives(filename)
      Hydra::Derivatives::ImageDerivatives.create(filename,
                                                  outputs: [{ label: :full,
                                                              format: 'jpg',
                                                              url: derivative_url('jpg'),
                                                              layer: 0 }])
    end


    def derivative_path_factory
      Hyrax::DerivativePath
    end
  end
end
