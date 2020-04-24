# frozen_string_literal: true
class HocrDerivativeService
    class Factory
      attr_reader :file_set, :filename, :processor_factory
      def initialize(file_set:, filename:, processor_factory: TesseractProcessor)
        @file_set = file_set
        @filename = filename
        @processor_factory = processor_factory
      end

      def new()
        HocrDerivativeService.new(file_set: file_set, filename: filename, processor_factory: processor_factory)
      end
    end

    attr_reader :file_set, :processor
    def initialize(file_set:, filename:, processor_factory:)
      @file_set = file_set
      @processor = processor_factory.new(ocr_language: 'eng', file_path: filename)
    end

    def create_derivatives
      result = processor.run!
      file_set.hocr_content << result.hocr_content
      file_set.ocr_content << result.ocr_content
    end

    # No cleanup necessary - all this does is set a property on FileSet.
    def cleanup_derivatives; end

    class TesseractProcessor
      attr_reader :ocr_language, :file_path
      def initialize(ocr_language:, file_path:)
        @ocr_language = ocr_language
        @file_path = file_path
      end

      def run!
        run_derivatives
        Result.new(hocr_content: created_file.read).tap do
          FileUtils.rm_f(created_file)
        end
      end

      class Result
        attr_reader :hocr_content
        def initialize(hocr_content:)
          @hocr_content = hocr_content
        end

        def ocr_content
          @ocr_content ||= ActionView::Base.full_sanitizer.sanitize(hocr_content).split("\n").map(&:strip).select(&:present?).join("\n")
        end
      end

      private

        def run_derivatives
          system("tesseract", file_path.to_s, temporary_output.path.to_s, "-l", ocr_language.to_s, "hocr", out: File::NULL, err: File::NULL)
        end

        def temporary_output
          @temporary_file ||= Tempfile.new
        end

        def created_file
          @created_file ||= File.open("#{temporary_output.path}.hocr")
        end
    end
  end