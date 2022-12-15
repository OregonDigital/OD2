# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class GettyBase
      def self.label(data)
        labels = find_all_labels(data)
        # Find an english label
        label = select_english_label(labels)
        label.count.positive? ? label.first['content'] : data.first['identified_by'][0]['content']
      end

      def self.select_english_label(labels)
        labels.select do |label|
          label['language'].any? { |t| t['id'].in? %i[http://vocab.getty.edu/language/en http://vocab.getty.edu/language/en-us] }
        end
      end

      def self.find_all_labels(data)
        # Find all possible labels
        data.first['identified_by'].select do |identifier|
          identifier['classified_as'].any? do |classification|
            classification['id'] == 'http://vocab.getty.edu/term/type/Descriptor'
          end
        end
      end

      def self.as_query(q)
        q + '.json'
      end
    end
  end
end
