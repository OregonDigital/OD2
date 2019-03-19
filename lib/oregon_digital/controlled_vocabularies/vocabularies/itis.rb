# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class Itis
      def self.expression
        %r{^http[s]?:\/\/www.itis.gov\/servlet\/SingleRpt\/SingleRpt\?search_topic=TSN&search_value=(.*)}
      end

      def self.label(data)
        data['scientificName']['combinedName']
      end

      def self.as_query(q)
        tsn = expression.match(q).captures.first
        "https://www.itis.gov/ITISWebService/jsonservice/getFullRecordFromTSN?tsn=#{tsn}"
      end
    end
  end
end
