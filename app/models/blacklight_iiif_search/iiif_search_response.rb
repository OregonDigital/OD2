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
      solr_response['response']['docs'].each do |document|
        hit = { '@type': 'search:Hit', 'annotations': [] }
        # Find which of our extracted text or hOCR fields this document has, then find the word:bbox string in that field for each searched word
        extract, ocr = document.values_at(*controller.blacklight_config.iiif_search[:full_text_field])
        # All words in corpus that are in any of the query words
        # word_array = (extract.nil? ? ocr : extract).select { |val| query.split(' ').map { |q_word| q_word.include?(val.split(':')[0]) }.reduce('|') }
        word_array = extract.nil? ? ocr_word_array(ocr) : extracted_word_array(extract, query)
        # BREAK
        # word_array is an array of [word:bbox] for each word in the search
        word_array.each_with_index do |word, index|
          # We're going to send the word_index over to app/models/concerns/blacklight_iiif_search/annotation_behavior.rb
          # The word stays the same, just the "hit highlight index" changes so the AnnotationBehavior can access the bbox
          annotation = IiifSearchAnnotation.new(document,
                                                query,
                                                index, word.text, controller,
                                                @parent_document)
          @resources << annotation.as_hash
          hit[:annotations] << annotation.annotation_id
        end
        @hits << hit
        # BREAK
      end
      @resources
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def extracted_word_array(extract, query)
      Nokogiri::HTML(extract[0]).css('word').select { |w| w.text.downcase.include? query }
    end

    def ocr_word_array(ocr) ; end

    def matches(matched_words, query)
      simplified_hash = {}
      q_words = query.split(' ')
      matched_words.each_key { |word|
        if word.to_s.include? q_word
          simp_hash[q_word] ||= []
          simp_hash[q_word] << test_words[key].flatten
        end
      }
      simp_hash = simp_hash.map { |k,v| [k, v.flatten] }.to_h

      matched_words = []
      simp_hash[q_words[0]].each_with_index { |word, start_pos|
        q_words[1..-1].each_with_index { |q_word, index|
          simp_hash[q_word]
        }
      }
    end

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
end
