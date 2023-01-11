# frozen_string_literal: true

module OregonDigital
  # Extract bounding box information and attach to fileset
  class ExtractedTextDerivativeService
    # Build ExtractedTextDerivativeService object
    class Factory
      attr_reader :file_set, :filename, :processor_factory
      def initialize(file_set:, filename:, processor_factory: PDFToTextProcessor)
        @file_set = file_set
        @filename = filename
        @processor_factory = processor_factory
      end

      def new
        ExtractedTextDerivativeService.new(file_set: file_set, filename: filename, processor_factory: processor_factory)
      end
    end

    attr_reader :file_set, :processor
    def initialize(file_set:, filename:, processor_factory:)
      @file_set = file_set
      @processor = processor_factory.new(file_path: filename)
    end

    # Extract PDF text and push all words into a hash
    # rubocop:disable Metrics/AbcSize
    def create_derivatives
      result = processor.run!
      # extracted text is derived from original PDF and isn't scaled when derivatives are created
      scale_factor = 4.175
      bbox_content = Nokogiri::HTML(result.bbox_content)
      bbox_content.css('word').each do |word|
        word['xmin'] = word['xmin'].to_i * scale_factor
        word['xmax'] = word['xmax'].to_i * scale_factor
        word['ymin'] = word['ymin'].to_i * scale_factor
        word['ymax'] = word['ymax'].to_i * scale_factor
      end

      file_set.bbox_content = bbox_content.to_s if bbox_content.css('word').count.positive?
    end
    # rubocop:enable Metrics/AbcSize

    # No cleanup necessary - all this does is set a property on FileSet.
    def cleanup_derivatives; end

    # Tesseract runner
    class PDFToTextProcessor
      attr_reader :file_path
      def initialize(file_path:)
        @file_path = file_path
      end

      def run!
        run_derivatives
        Result.new(bbox_content: created_file.read).tap do
          FileUtils.rm_f(created_file)
        end
      end

      # OCR result
      class Result
        attr_reader :bbox_content
        def initialize(bbox_content:)
          @bbox_content = bbox_content
        end
      end

      private

      def run_derivatives
        system('pdftotext', '-bbox', file_path.to_s, temporary_output.path.to_s, out: File::NULL, err: File::NULL)
      end

      def temporary_output
        @temporary_output ||= Tempfile.new
      end

      def created_file
        @created_file ||= File.open(temporary_output.path)
      end
    end
  end
end
