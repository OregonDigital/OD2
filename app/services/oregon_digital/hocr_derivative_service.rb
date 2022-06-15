# frozen_string_literal: true

module OregonDigital
  # OCR files and attach to fileset
  class HocrDerivativeService
    # Build HocrDerivativeService object
    class Factory
      attr_reader :file_set, :filename, :pagenum, :processor_factory
      def initialize(file_set:, filename:, pagenum:, processor_factory: TesseractProcessor)
        @file_set = file_set
        @filename = filename
        @pagenum = pagenum
        @processor_factory = processor_factory
      end

      def new
        HocrDerivativeService.new(file_set: file_set, filename: filename, pagenum: pagenum, processor_factory: processor_factory)
      end
    end

    attr_reader :file_set, :processor
    def initialize(file_set:, filename:, pagenum:, processor_factory:)
      @file_set = file_set
      @pagenum = pagenum
      @processor = processor_factory.new(ocr_language: 'eng', file_path: filename)

      @file_set.ocr_content = [] if @file_set.ocr_content.nil?
      @file_set.hocr_content = {} if @file_set.hocr_content.nil?
    end

    # OCR text and push all words into a hash, which will be serialized later in OregonDigital::FileSetDerivativesService
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create_derivatives
      result = processor.run!
      @file_set.hocr_content ||= {}
      @file_set.hocr_text    ||= []
      words = Nokogiri::HTML(result.hocr_content).css('.ocrx_word')

      @file_set.hocr_text << words.map do |nokogiri_element|
        nokogiri_element.text
      end.join(' ')
      # Create a hash of words and their bounding boxes
      # hOCR is returned as an xml doc string for the current page
      # For each word on the page parse out the bbox position and downcased+stemmed word
      word_count = words.count
      words.each_with_index do |nokogiri_element, word|
        Rails.logger.debug("word #{word}/#{word_count}") if (word % 10).zero?
        coords = nokogiri_element.attributes['title'].value.split(';').find { |x| x.include?('bbox') }.gsub('bbox ', '').split(' ')

        @file_set.hocr_content[nokogiri_element.text.downcase.stem] ||= []
        @file_set.hocr_content[nokogiri_element.text.downcase.stem] << "#{coords[0]},#{coords[1]},#{coords[2]},#{coords[3]},#{@pagenum}"
      end

      @file_set.ocr_content << result.ocr_content
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # No cleanup necessary - all this does is set a property on FileSet.
    def cleanup_derivatives; end

    # Tesseract runner
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

      # OCR result
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
        system('tesseract', file_path.to_s, temporary_output.path.to_s, '-l', ocr_language.to_s, 'hocr', out: File::NULL, err: File::NULL)
      end

      def temporary_output
        @temporary_output ||= Tempfile.new
      end

      def created_file
        @created_file ||= File.open("#{temporary_output.path}.hocr")
      end
    end
  end
end
