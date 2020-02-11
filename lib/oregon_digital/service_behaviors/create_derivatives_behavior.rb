# frozen_string_literal: true

module OregonDigital
  # This is an extraction which keeps all the create derivative methods together. This lowers the amount of lines in the included class
  # and also keeps like functionality together.
  module ServiceBehaviors::CreateDerivativesBehavior
    extend ActiveSupport::Concern
    included do
      # Overridden: we need our image derivatives to be 100% done our way, not the Hyrax way
      def create_image_derivatives(filename)
        OregonDigital::Derivatives::Image::Utils.tmp_file('png') do |out_path|
          preprocess_image(filename, out_path)
          create_thumbnail(out_path)
          create_zoomable(out_path)
        end
      end

      # Overridden: Office documents' needs are very similar to base Hyrax, but
      # we can't use `mogrify` with a `flatten` switch in GraphicsMagick-land, so
      # we have a slightly modified copy of the core processor
      def create_office_document_derivatives(filename)
        extract_full_text(filename, uri)
        OregonDigital::Derivatives::Document::Runner.create(
          filename,
          outputs: [{ label: :thumbnail, size: '200x150>',
                      format: 'jpg', url: derivative_url('thumbnail'), layer: 0 }]
        )
      end

      def create_pdf_derivatives(filename)
        create_thumbnail(filename)
        extract_full_text(filename, uri)
        page_count = OregonDigital::Derivatives::Image::Utils.page_count(filename)
        0.upto(page_count - 1) do |pagenum|
          OregonDigital::Derivatives::Image::Utils.tmp_file('png') do |out_path|
            manual_convert(filename, pagenum, out_path)
            create_zoomable_page(out_path, pagenum)
          end
        end
      end

      def create_thumbnail(filename)
        OregonDigital::Derivatives::Image::GMRunner.create(
          filename,
          outputs: [{ label: :thumbnail, size: '120x120>',
                      format: 'jpg', url: derivative_url('thumbnail'), layer: 0 }]
        )
      end

      def create_zoomable(filename)
        create_zoomable_page(filename, nil)
      end

      def create_zoomable_page(filename, pagenum)
        OregonDigital::Derivatives::Image::JP2Runner.create(filename,
                                                            outputs: [{ label: :jp2,
                                                                        mime_type: mime_type,
                                                                        url: derivative_url('jp2', pagenum),
                                                                        tile_size: '1024',
                                                                        compression: '20',
                                                                        layer: 0 }])
      end
    end
  end
end
