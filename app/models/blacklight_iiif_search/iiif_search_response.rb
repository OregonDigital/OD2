# frozen_string_literal: true

module BlacklightIiifSearch
  # corresponds to a IIIF Annotation List
  class IiifSearchResponse
    include BlacklightIiifSearch::Ignored

    attr_reader :solr_response, :controller, :iiif_config

    ##
    # @param [Blacklight::Solr::Response] solr_response
    # @param [SolrDocument] parent_document
    # @param [CatalogController] controller
    def initialize(solr_response, parent_document, controller)
      @solr_response = solr_response
      @parent_document = parent_document
      @controller = controller
      @iiif_config = controller.iiif_search_config
      @resources = []
      @hits = []
    end

    ##
    # constructs the IIIF::Presentation::AnnotationList
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # @return [IIIF::OrderedHash]
    def annotation_list
      list_id = controller.request.original_url
      anno_list = IIIF::Presentation::AnnotationList.new('@id' => list_id)
      anno_list['@context'] = %w[
        http://iiif.io/api/presentation/2/context.json
        http://iiif.io/api/search/1/context.json
      ]
      anno_list['resources'] = resources
      anno_list['hits'] = @hits
      anno_list['within'] = within
      anno_list['prev'] = paged_url(solr_response.prev_page) if solr_response.prev_page
      anno_list['next'] = paged_url(solr_response.next_page) if solr_response.next_page
      anno_list['startIndex'] = 0 unless solr_response.total_pages > 1
      anno_list.to_ordered_hash(force: true, include_context: false)
    end

    ##
    # Return an array of IiifSearchAnnotation objects
    # OVERRIDE FROM BLACKLIGHT_IIIF_SEARCH: To circumvent using Solr hit-highlighting. Parsing our OCR'd storage field is more accurate
    # @return [Array]
    def resources
      @total = 0
      query = solr_response.params['q'].delete_suffix('*').downcase
      query_length = query.strip.split(' ').length
      solr_response['response']['docs'].each do |document|
        hit = { '@type': 'search:Hit', 'annotations': [] }
        # Prepare to find ocr and hocr derivative file uris
        sd = SolrDocument.new(document)
        fds = OregonDigital::FileSetDerivativesService.new(sd)

        # Get the bbox content
        bbox_content = sd.bbox_content

        # Check for bbox first
        all_words = unless bbox_content.blank?
          extracted_word_array(bbox_content)
        else
          # Otherwise use hocr
          ocr_word_array(sd.hocr)
        end

        word_array = match_words(all_words, query)

        # word_array is an array of BlacklightIiifSearch::Word for each word in the document
        word_array.each_slice(query_length).with_index do |words, index|
          text = words.map(&:text).join(' ')
          annotation = IiifSearchAnnotation.new(document,
                                                query,
                                                index, text, controller,
                                                @parent_document)
          # Send word_array over to app/models/concerns/blacklight_iiif_search/annotation_behavior.rb to create coordinates
          annotation.found_words = words

          @resources << annotation.as_hash
          hit[:annotations] << annotation.annotation_id
        end
        @hits << hit
      end
      @total = @hits[0][:annotations].count unless @hits.blank?
      @resources
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # Create Word objects for all extracted words
    # @param [String] Output from `pdftotext`
    def extracted_word_array(extract)
      # Create ordered BlacklightIiifSearch::Word objects for every word in the PDF
      extract.map do |text|
        Nokogiri::HTML(text).css('page').map.with_index do |page, page_number|
          page.css('word').map do |word|
            Word.new([word.attr('xmin'), word.attr('ymin'), word.attr('xmax'), word.attr('ymax')], page_number, word.text)
          end.flatten
        end.flatten
      end.flatten
    end

    # Create Word objects for all extracted words
    # @param [String] Output from `tesseract`
    # rubocop:disable Metrics/AbcSize
    def ocr_word_array(hocr_files)
      hocr_files.map.with_index do |file, page_number|
        text = file.content
        # Create ordered BlacklightIiifSearch::Word objects for every word in the PDF
        Nokogiri::HTML(text).css('.ocrx_word').map do |word|
          bbox_info = word.attr('title').split(';')[0].sub('bbox ', '').split(' ')

          Word.new([bbox_info[0], bbox_info[1], bbox_info[2], bbox_info[3]], page_number, word.text)
        end.flatten
      end.flatten
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize
    def match_words(words, query)
      # Query as an array
      word_queries = query.strip.split(' ')
      matches = []

      # Find the matches
      words.each_with_index do |word, index|
        # Check if this word matches the begining of the query
        next unless word.text.downcase.include?(word_queries.first)
        # Check if there is enough words left to match whole query phrase
        next unless index + word_queries.length - 1 < words.length

        # If the whole query phrase matches from the first word to the last, we've found a match!
        matches |= words[index..index + word_queries.length - 1] if words[index..index + word_queries.length - 1].map(&:text).join(' ').downcase.include?(query)
      end

      matches
    end
    # rubocop:enable Metrics/AbcSize

    ##
    # @return [IIIF::Presentation::Layer]
    def within
      within_hash = IIIF::Presentation::Layer.new
      within_hash['ignored'] = ignored
      if solr_response.total_pages > 1
        within_hash['first'] = paged_url(1)
        within_hash['last'] = paged_url(solr_response.total_pages)
      else
        within_hash['total'] = @total
      end
      within_hash
    end

    ##
    # create a URL for the previous/next page of results
    # @return [String]
    def paged_url(page_index)
      controller.solr_document_iiif_search_url(clean_params.merge(page: page_index))
    end

    ##
    # remove ignored or irrelevant params from the params hash
    # @return [ActionController::Parameters]
    def clean_params
      remove = ignored.map(&:to_sym)
      controller.iiif_search_params.except(*%i[page solr_document_id] + remove)
    end
  end

  # A single word and bounding box
  class Word
    attr_reader :bbox_coords
    attr_accessor :page, :text
    def initialize(bbox_coords, page, text)
      @bbox_coords = bbox_coords
      @page = page
      @text = text
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
