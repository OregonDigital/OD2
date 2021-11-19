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

    def create_derivatives
      result = processor.run!
      words_hash = {}

      pages = Nokogiri::HTML(result.bbox_content).css('page')
      page_count = pages.count
      word_count = Nokogiri::HTML(result.bbox_content).css('word')

      pages.each_with_index do |doc, page|
        # page = nokogiri_element.ancestors('page').xpath('preceding-sibling::page').count
        words = doc.css('word')
        word_count = words.count
        words.each_with_index do |nokogiri_element, word|
          Rails.logger.debug("word #{word}/#{word_count} on page #{page}/#{page_count}")

          x = nokogiri_element.attributes['xmin'].value.to_i
          y = nokogiri_element.attributes['ymin'].value.to_i
          x2 = nokogiri_element.attributes['xmax'].value.to_i
          y2 = nokogiri_element.attributes['ymax'].value.to_i

          scale_factor = 4.185
          coords = [x, y, x2, y2].map { |coord| coord * scale_factor }

          words_hash[nokogiri_element.text.downcase.stem] ||= []
          words_hash[nokogiri_element.text.downcase.stem] << "#{coords[0]},#{coords[1]},#{coords[2]},#{coords[3]},#{page}"
        end
      end

      solr_doc = []
      words_hash.each do |word,coords|
        solr_doc << "#{word}:#{coords.join(';')}"
      end

      file_set.bbox_content = solr_doc
      # file_set.bbox_content = [result.bbox_content]
    end

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
