# frozen_string_literal: true

module OregonDigital
  # Label parser to get both the label and uri
  class LabelParserService
    # METHOD: Parse out the label and the uri
    def self.parse_label_uris(labels)
      # CHECK: If labels exist return it, else return empty array
      # CREATE: Setup an empty array to store the hash of label and uri to return
      labels ||= []
      parsed_label_uris = []

      # LOOP: Loop through each labels and parse out the content and assign to the right key value
      labels.each do |label|
        parsed_label_uris << { 'label' => strip_uri(label), 'uri' => strip_label(label) }
      end

      # RETURN: Return all the parse out label and uri
      parsed_label_uris
    end

    # METHOD: Parse out the label only
    def self.parse_labels(labels)
      # CHECK: If labels exist return it, else return empty array
      # CREATE: Setup an empty array to store the label
      labels ||= []
      parsed_labels = []

      # LOOP: Go through each labels and parse out the label only
      labels.each do |label|
        parsed_labels << strip_uri(label)
      end

      # RETURN: Return array full of the labels
      parsed_labels
    end

    # rubocop:disable Lint/UselessAccessModifier
    # rubocop:disable Lint/IneffectiveAccessModifier
    private

    # METHOD: Stripping out the uri and mapping to the label
    def self.strip_uri(label)
      items = build_array(label)
      items[0...-1].join('$')
    end

    # METHOD: Stripping out the label and mapping to the uri
    def self.strip_label(label)
      items = build_array(label)
      items.last
    end

    # METHOD: Split the string up at the $ symbol
    def self.build_array(label)
      label&.split('$') || []
    end
    # rubocop:enable Lint/UselessAccessModifier
    # rubocop:enable Lint/IneffectiveAccessModifier
  end
end
