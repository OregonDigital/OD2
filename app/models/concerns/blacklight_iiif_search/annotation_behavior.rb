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
    # rubocop:disable Metrics/AbcSize
    def coordinates
      return '' unless query

      # Attempt to grab extracted text if it exists
      @extracted_words ||= find_words('all_text_bbox_tsimv')
      # hOCR text is guaranteed to exist because it's automatically part of the derivative process
      @hocr_words ||= find_words('hocr_content_tsimv')

      # Use extracted words when possible, but fall back to hOCR
      word = @hocr_words[hl_index]
      word = @extracted_words[hl_index] if @extracted_words && @extracted_words[hl_index]

      # Write out bbox info
      word ? "#{word.page}#xywh=#{word.bbox}" : '0#xywh=0,0,0,0'
      # There were no matching words in extracted or OCRd text, write out an empty result.
    end
    # rubocop:enable Metrics/AbcSize

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

    # A single search result word and bounding box
    class Word
      attr_reader :bbox_coords
      def initialize(bbox_coords)
        @bbox_coords = bbox_coords
      end

      # Bounding box information is sent in as [x, y, x2, y2, page], so just pass the coords to a BoundingBox
      def bbox
        coords = [bbox_coords[0], bbox_coords[1], bbox_coords[2], bbox_coords[3]]

        @bbox ||= BoundingBox.new(coords)
      end

      def page
        @page ||= bbox_coords[4].to_i
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

        def to_s
          "#{x},#{y},#{w},#{h}"
        end
      end
    end
  end
end
