# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Wikidata
      def self.expression
        %r{^http[s]?:\/\/(www.)?wikidata.org\/entity\/.*}
      end

      def self.label(data)
        data.first['entities'].first.second['labels'][I18n.locale.to_s]['value']
      end

      def self.as_query(q)
        q
      end
    end
  end
end
