# frozen_string_literal: true

module BlacklightIiifSearch
  # customizable behavior for IiifSearchAnnotation
  module AnnotationBehavior
    attr_writer :found_words
    ##
    # Create a URL for the annotation
    # @return [String]
    def annotation_id
      "#{parent_url}/canvas/#{document[:id]}/annotation/#{query.sub(' ', '_')}-#{hl_index/2}"
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

      word = @found_words[hl_index]

      # Write out bbox info
      word ? "#{word.page}#xywh=#{word.bbox}" : '0#xywh=0,0,0,0'
      # There were no matching words in extracted or OCRd text, write out an empty result.
    end
  end
end
