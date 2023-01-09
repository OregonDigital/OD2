# frozen_string_literal: true

module BlacklightIiifSearch
  # customizable behavior for IiifSearchAnnotation
  module AnnotationBehavior
    ##
    # Create a URL for the annotation
    # @return [String]
    def annotation_id
      "#{parent_url}/canvas/#{document[:id]}/annotation/#{query}-#{hl_index}"
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
      controller.manifest_hyrax_generic_url(parent_document[:id]).gsub(/\?locale=.*/, '').gsub('localhost', 'test.library.oregonstate.edu').gsub(/generic/, parent_document['has_model_ssim'][0].downcase)
    end

    ##
    # return a string like "#xywh=100,100,250,20"
    # corresponding to coordinates of query term on image
    # local implementation expected, value returned below is just a placeholder
    # @return [String]
    def coordinates
      return '' unless query

      # Attempt to grab extracted text if it exists
      @extracted_words ||= find_extract_words
      # hOCR text is guaranteed to exist because it's automatically part of the derivative process
      @hocr_words ||= []# find_ocr_words('hocr_content_tsimv')

      # Use extracted words when possible, but fall back to hOCR
      word = @hocr_words[hl_index]
      word = @extracted_words[hl_index] if @extracted_words && @extracted_words[hl_index]

      # Write out bbox info
      word ? "#{word.page}#xywh=#{word.bbox}" : '0#xywh=0,0,0,0'
      # There were no matching words in extracted or OCRd text, write out an empty result.
    end

    # rubocop:disable Metrics/AbcSize
    def find_words(solr_field)
      return [] unless document[solr_field]

      # Begin by grabbing the output of `pdftotext -bbox`
      text = document[solr_field].select { |val| val.split(':')[0] == query }
      # Find each individual word
      bboxes = text.map { |val| val.split(':')[1].split(';') }.flatten
      # Create ExtractedWord objects out of the words
      bboxes.map do |box|
        Word.new(box.split(',').map(&:to_f))
      end
    end
    # rubocop:enable Metrics/AbcSize

    def find_extract_words
      text = document['all_text_bbox_tsimv']
      return [] unless text

      text.map do |t|
        Nokogiri::HTML(t).css('page').map.with_index do |page, page_number|
          words = page.css('word').select { |w| w.text.downcase.include? query }.map do |word|
            # BREAK
            Word.new([word.attr('xmin'), word.attr('ymin'), word.attr('xmax'), word.attr('ymax')], page_number)
          end.flatten
        end.flatten
      end.flatten
    end

    # A single search result word and bounding box
    class Word
      attr_reader :bbox_coords
      attr_accessor :page
      def initialize(bbox_coords, page)
        @bbox_coords = bbox_coords
        @page = page
      end

      # Bounding box information is sent in as [x, y, x2, y2, page], so just pass the coords to a BoundingBox
      def bbox
        coords = [bbox_coords[0], bbox_coords[1], bbox_coords[2], bbox_coords[3]]

        @bbox ||= BoundingBox.new(coords)
      end

      # Bounding box to a word
      # x,y coords and width/height
      class BoundingBox
        attr_reader :x, :y, :w, :h
        def initialize(box_array)
          scale = 4.175
          @x = (box_array[0].to_i * scale).floor
          @y = (box_array[1].to_i * scale).floor
          @w = (box_array[2].to_i * scale - @x).floor
          @h = (box_array[3].to_i * scale - @y).floor
        end

        def to_s
          "#{x},#{y},#{w},#{h}"
        end
      end
    end
  end
end
