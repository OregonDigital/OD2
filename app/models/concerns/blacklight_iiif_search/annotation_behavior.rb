# frozen_string_literal: true

module BlacklightIiifSearch
  # customizable behavior for IiifSearchAnnotation
  module AnnotationBehavior
    ##
    # Create a URL for the annotation
    # @return [String]
    def annotation_id
      "#{parent_url}/canvas/#{document[:id]}/annotation/#{hl_index}"
    end

    ##
    # Create a URL for the canvas that the annotation refers to
    # @return [String]
    def canvas_uri_for_annotation
      "#{parent_url}/canvas/#{document[:id]}/#{coordinates}"
    end

    # Get the parent manifest URL
    def parent_url
      # Get the manifest URL for a Generic work, and sub in the correct model name
      controller.manifest_hyrax_generic_url(parent_document[:id]).gsub(/\?locale=.*/, '').gsub(/generic/, parent_document['has_model_ssim'][0].downcase).sub('localhost', 'test.library.oregonstate.edu')
    end

    ##
    # return a string like "#xywh=100,100,250,20"
    # corresponding to coordinates of query term on image
    # local implementation expected, value returned below is just a placeholder
    # @return [String]
    # rubocop:disable Metrics/AbcSize
    def coordinates
      query.delete_suffix!('*')
      query.downcase!
      return '' unless query

      # Attempt to read from extracted text first, if there's no bounding boxes or matching word move on
      if document['all_text_bbox_tsimv'] && (word = extracted_words[hl_index])
        "#{word.page}#xywh=#{word.bbox.x},#{word.bbox.y},#{word.bbox.w},#{word.bbox.h}"
      # Next try OCRd text, if there's no matching words move on
      elsif (word = hocr_words[hl_index])
        "#{word.page}#xywh=#{word.bbox.x},#{word.bbox.y},#{word.bbox.w},#{word.bbox.h}"
      # There were no matching words in extracted or OCRd text, there's no matches.
      else
        '0#xywh=0,0,0,0'
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Search all extracted words to find matches
    # @return [ExtractedWord]
    def extracted_words
      @extracted_words ||=
        begin
          # Begin by grabbing the output of `pdftotext -bbox`
          text = document['all_text_bbox_tsimv'].select do |val|
            val.start_with? *query.split(' ')
          end
          # Find each individual word
          bboxes = text.map do |val|
            val.split(':')[1].split(';')
          end.flatten
          # Create ExtractedWord objects out of the words
          words = bboxes.map do |box|
            pos = box.split(',').map(&:to_f)
            ExtractedWord.new(pos)
          end
        end
    end

    # Convert extracted word XML to ExtractedWord objects
    # @return [ExtractedWord]
    def to_extracted_words(nokogiri_element)
      # Find each individual word
      words = nokogiri_element.css('word')
      # Create ExtractedWord objects out of the words
      words.map { |x| ExtractedWord.new(x) }
    end

    # Search all OCR'd words to find matches
    # @return [HocrWord]
    # rubocop:disable Metrics/AbcSize
    def hocr_words
      @hocr_words ||=
        document['hocr_content_tsimv'].map.with_index do |doc, i|
          # Begin by grabbing the output of `tesseract hocr`
          text = document['all_text_bbox_tsimv'].select do |val|
            val.start_with? *query.split(' ')
          end
          # Find each individual word
          bboxes = text.map do |val|
            val.split(':')[1].split(';')
          end.flatten
          # Create HocrWord objects out of the words
          words = bboxes.map do |box|
            pos = box.split(',').map(&:to_f)
            ExtractedWord.new(pos)
          end
        end.flatten
    end
    # rubocop:enable Metrics/AbcSize

    # Convert OCR'd XML to HocrWord objects
    # @return [HocrWord]
    def to_hocr_words(nokogiri_element, page)
      # Find each individual word
      words = nokogiri_element.css('.ocrx_word')
      # Create HocrWord objects out of the words
      words.map { |x| HocrWord.new(x, page) }
    end

    # A single search result word and bounding box
    class Word
      attr_reader :nokogiri_element
      def initialize(nokogiri_element)
        @nokogiri_element = nokogiri_element
      end

      def text
        @text ||= nokogiri_element.text
      end

      # Bounding box to a word
      # x,y coords and width/height
      class BoundingBox
        attr_reader :x, :y, :w, :h
        def initialize(box_array)
          @x = box_array[0].to_i
          @y = box_array[1].to_i
          @w = box_array[2].to_i - @x
          @h = box_array[3].to_i - @y
        end
      end
    end

    # Implementation of Word for hOCR data
    class HocrWord < Word
      attr_reader :page
      def initialize(nokogiri_element, page)
        @page = page
        super(nokogiri_element)
      end

      # Bounding box information is found inside the title attribute of hOCR elements
      # Example element: <span class='ocrx_word' id='word_1_3' title='bbox 452 312 538 348; x_wconf 96'>This</span>
      def bbox
        @bbox ||= BoundingBox.new(nokogiri_element.attributes['title'].value.split(';').find { |x| x.include?('bbox') }.gsub('bbox ', '').split(' '))
      end
    end

    # Implementation of Word for extracted text
    class ExtractedWord < Word
      # Bounding box information is found inside custom attributes of the word element
      # Example element: <word xMin="108.000000" yMin="72.588000" xMax="129.468000" yMax="85.872000">This</word>
      # rubocop:disable Metrics/AbcSize
      def bbox
        x = nokogiri_element[0]
        y = nokogiri_element[1]
        x2 = nokogiri_element[2]
        y2 = nokogiri_element[3]

        coords = [x, y, x2, y2]

        @bbox ||= BoundingBox.new(coords)
      end
      # rubocop:enable Metrics/AbcSize

      # Pages are in-order elements with word children
      # Example element:
      # <page width="612.000000" height="792.000000">
      #   <word xMin="494.880000" yMin="36.049920" xMax="532.206240" yMax="49.529760">Beskow,</word>
      #   <word xMin="534.720000" yMin="36.049920" xMax="540.317280" yMax="49.529760">5</word>
      #   <word xMin="108.000000" yMin="72.588000" xMax="129.468000" yMax="85.872000">This</word>...
      def page
        @page ||= nokogiri_element[4].to_i
      end
    end
  end
end
