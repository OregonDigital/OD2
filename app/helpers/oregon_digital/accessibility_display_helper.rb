# frozen_string_literal:true

module OregonDigital
  # Application wide helper to contain display help for accessibility feature
  module AccessibilityDisplayHelper
    # List of known acronyms to preserve exactly as written
    ACRONYMS = %w[PDF TTS MathML ChemML HTML XML].freeze

    # METHOD: To humanize the display for the accessibility
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    def accessibility_display(str)
      result = str.split('-').map do |segment|
        # If exact acronym
        if ACRONYMS.include?(segment)
          segment
        # Else if the word starts with acronym
        elsif (acronym = ACRONYMS.find { |ac| segment.start_with?(ac) })
          rest = segment[acronym.length, segment.length - acronym.length]
          # split camelCase after acronym
          rest = rest.gsub(/([a-z])([A-Z])/, '\1 \2')
          rest_words = rest.split.map(&:capitalize)
          [acronym, rest_words.join(' ')].reject(&:empty?).join(' ')
        else
          # Else, normalize camelCase
          segment.gsub(/([a-z])([A-Z])/, '\1 \2').split.map(&:capitalize).join(' ')
        end
      end.join('-')

      # Final pass; replace any words that match known acronyms
      result.split.map { |w| w.include?('Pdf') || w.include?('Tts') ? w.upcase : w }.join(' ')
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
