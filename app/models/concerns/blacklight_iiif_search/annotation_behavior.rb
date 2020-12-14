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
      controller.manifest_hyrax_document_url(parent_document[:id]).gsub(/\?locale=.*/, '')
    end

    ##
    # return a string like "#xywh=100,100,250,20"
    # corresponding to coordinates of query term on image
    # local implementation expected, value returned below is just a placeholder
    # @return [String]
    def coordinates
      return '' unless query

      if (word = words[hl_index])
        "#{word.page}#xywh=#{word.bbox.x},#{word.bbox.y},#{word.bbox.w},#{word.bbox.h}"
      else
        '0#xywh=0,0,0,0'
      end
    end

    def words
      @words ||=
        begin
          found_words = []
          document['hocr_content_tsimv'].each_with_index do |hocr, page|
            hocr = Nokogiri::HTML(hocr)
            words = hocr.css('.ocrx_word')
            words = words.map { |x| Word.new(x, page) }
            found_words += words.select { |x| x.text.downcase =~ /#{query.downcase}[,.! ]?$/ }
          end
          found_words
        end
    end

    # A single search result word and bounding box
    class Word
      attr_reader :nokogiri_element, :page
      def initialize(nokogiri_element, page)
        @nokogiri_element = nokogiri_element
        @page = page
      end

      def bbox
        @bbox ||= BoundingBox.new(nokogiri_element.attributes['title'].value.split(';').find { |x| x.include?('bbox') }.gsub('bbox ', '').split(' '))
      end

      def text
        @text ||= nokogiri_element.text
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
  end
end
