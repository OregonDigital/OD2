# frozen_string_literal: true

module BlacklightIiifSearch
  # customizable behavior for IiifSearchAnnotation
  module AnnotationBehavior
    attr_writer :found_words
    ##
    # Create a URL for the annotation
    # @return [String]
    def annotation_id
      "#{parent_url}/canvas/#{document[:id]}/annotation/#{query.gsub(' ', '_')}-#{hl_index}"
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

      bbox = {
        x: @found_words[0].bbox.x,
        y: @found_words[0].bbox.y,
        w: continuous_words_width,
        h: @found_words[0].bbox.h
      }

      # Write out bbox info
      # There were no matching words in extracted or OCRd text, write out an empty result.
      @found_words ? "#{@found_words[0].page}#xywh=#{bbox.values.join(',')}" : '0#xywh=0,0,0,0'
    end

    ##
    # return a number equal to the width of a bounding box that surrounds the first matched word
    #   and all following words on the same line
    def continuous_words_width
      # All words, starting from the first, found on a single line
      continuous_words = @found_words.select { |f| f.bbox.x >= @found_words[0].bbox.x }.map(&:bbox)
      # (the very last x point) - the very first x point == total width
      (continuous_words[-1].x + continuous_words[-1].w) - continuous_words[0].x
    end
  end
end
