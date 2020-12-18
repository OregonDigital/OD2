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
      controller.manifest_hyrax_generic_url(parent_document[:id]).gsub(/\?locale=.*/, '').gsub(/generic/, parent_document['has_model_ssim'][0].downcase)
    end

    ##
    # return a string like "#xywh=100,100,250,20"
    # corresponding to coordinates of query term on image
    # local implementation expected, value returned below is just a placeholder
    # @return [String]
    # rubocop:disable Metrics/AbcSize
    def coordinates
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
          text = Nokogiri::HTML(document['all_text_bbox_tsimv'][0])
          # Find each individual word
          words = text.css('word')
          # Create ExtractedWord objects out of the words
          words = words.map { |x| ExtractedWord.new(x) }
          # Select only words that match the query and return an in-order array of ExtractedWords
          words.select { |x| x.text.downcase =~ /#{query.downcase}[,.! ]?$/ }
        end
    end

    # Search all OCR'd words to find matches
    # @return [HocrWord]
    def hocr_words
      @hocr_words ||=
        begin
          # Begin by grabbing the output of `tesseract hocr`
          hocr = Nokogiri::HTML(document['hocr_content_tsimv'][0])
          # Find each individual word
          words = hocr.css('.ocrx_word')
          # Create HocrWord objects out of the words
          words = words.map { |x| HocrWord.new(x) }
          # Select only words that match the query and return an in-order array of HocrWord
          words.select { |x| x.text.downcase =~ /#{query.downcase}[,.! ]?$/ }
        end
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
      # Bounding box information is found inside the title attribute of hOCR elements
      # Example element: <span class='ocrx_word' id='word_1_3' title='bbox 452 312 538 348; x_wconf 96'>This</span>
      def bbox
        @bbox ||= BoundingBox.new(nokogiri_element.attributes['title'].value.split(';').find { |x| x.include?('bbox') }.gsub('bbox ', '').split(' '))
      end

      # Pages are ancestors to the word and the page number is of the form 'page_#' in the id
      # Example element: <div class='ocr_page' id='page_1' title='image "/tmp/od220201217-1-1aadfbx.png"; bbox 0 0 2550 3300; ppageno 0'>
      def page
        @page ||= nokogiri_element.ancestors('.ocr_page').attribute('id').value.split('_')[1].to_i - 1
      end
    end

    # Implementation of Word for extracted text
    class ExtractedWord < Word
      # Bounding box information is found inside custom attributes of the word element
      # Example element: <word xMin="108.000000" yMin="72.588000" xMax="129.468000" yMax="85.872000">This</word>
      # rubocop:disable Metrics/AbcSize
      def bbox
        scale_factor = 4.185
        x = nokogiri_element.attributes['xmin'].value.to_i
        y = nokogiri_element.attributes['ymin'].value.to_i
        x2 = nokogiri_element.attributes['xmax'].value.to_i
        y2 = nokogiri_element.attributes['ymax'].value.to_i

        coords = [x, y, x2, y2].map { |coord| coord * scale_factor }

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
        @page ||= nokogiri_element.ancestors('page').xpath('preceding-sibling::page').count
      end
    end
  end
end
