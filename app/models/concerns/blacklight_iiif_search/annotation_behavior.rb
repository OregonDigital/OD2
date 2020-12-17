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

    def parent_url
      controller.manifest_hyrax_document_url(parent_document[:id]).gsub(/\?locale=.*/, '').gsub(/document/, parent_document['has_model_ssim'][0].downcase)
    end

    ##
    # return a string like "#xywh=100,100,250,20"
    # corresponding to coordinates of query term on image
    # local implementation expected, value returned below is just a placeholder
    # @return [String]
    def coordinates
      return '' unless query

      if (document['all_text_bbox_tsimv'] && word = extracted_words[hl_index])
        "#{word.page}#xywh=#{word.bbox.x},#{word.bbox.y},#{word.bbox.w},#{word.bbox.h}"
      elsif (word = hocr_words[hl_index])
        "#{word.page}#xywh=#{word.bbox.x},#{word.bbox.y},#{word.bbox.w},#{word.bbox.h}"
      else
        '0#xywh=0,0,0,0'
      end
    end

    def extracted_words
      @extracted_words ||=
        begin
          text = Nokogiri::HTML(document['all_text_bbox_tsimv'][0])
          words = text.css('word')
          words = words.map { |x| ExtractedWord.new(x) }
          words.select { |x| x.text.downcase =~ /#{query.downcase}[,.! ]?$/ }
        end
    end

    def hocr_words
      @hocr_words ||=
        begin
          hocr = Nokogiri::HTML(document['hocr_content_tsimv'][0])
          words = hocr.css('.ocrx_word')
          words = words.map { |x| HocrWord.new(x) }
          words.select { |x| x.text.downcase =~ /#{query.downcase}[,.! ]?$/ }
        end
    end

    # A single search result word and bounding box
    class Word
      attr_reader :nokogiri_element
      def initialize(nokogiri_element)
        @nokogiri_element = nokogiri_element
      end

      # Bounding box to a word
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

    class HocrWord < Word
      def bbox
        @bbox ||= BoundingBox.new(nokogiri_element.attributes['title'].value.split(';').find { |x| x.include?('bbox') }.gsub('bbox ', '').split(' '))
      end

      def text
        @text ||= nokogiri_element.text
      end

      def page
        @page ||= nokogiri_element.ancestors('.ocr_page').attribute('id').value.split('_')[1].to_i - 1
      end
    end

    class ExtractedWord < Word
      def bbox
        x = nokogiri_element.attributes['xmin'].value.to_i * 4.185
        y = nokogiri_element.attributes['ymin'].value.to_i * 4.185
        x2 = nokogiri_element.attributes['xmax'].value.to_i * 4.185
        y2 = nokogiri_element.attributes['ymax'].value.to_i * 4.185
        @bbox ||= BoundingBox.new([x, y, x2, y2])
      end

      def text
        @text ||= nokogiri_element.text
      end

      def page
        @page ||= nokogiri_element.ancestors('page').xpath('preceding-sibling::page').count
      end
    end
  end
end
