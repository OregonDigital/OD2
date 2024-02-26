# frozen_string_literal:true

module OregonDigital
  # Validates EDTF format on a list of date fields
  module TextExtractedBehavior
    extend ActiveSupport::Concern

    included do
      def hocr_text
        @hocr_text ||= begin
          fds = OregonDigital::FileSetDerivativesService.new(self)
          uris = fds.sorted_derivative_urls('hocr')
          uris.map do |path|
            hocr_text = File.read(path.sub('file://', ''))
            Nokogiri::HTML(hocr_text).css('.ocrx_word').map(&:text).join(' ')
          end
        rescue
          nil
        end
        @hocr_text ||= hocr_content
      end

      # Find legacy hocr text
      # Remove after all text/hocr text derivative creation
      def hocr_content
        @hocr_content ||= SolrDocument.find(id).to_h.dig('hocr_content_tsimv')
      rescue Blacklight::Exceptions::RecordNotFound
        nil
      end
    end
  end
end
