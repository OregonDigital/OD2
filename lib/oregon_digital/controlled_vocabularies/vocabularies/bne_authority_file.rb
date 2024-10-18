# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies::Vocabularies
    # Receives information pulled from the endpoint and can parse and generate queries
    class BneAuthorityFile
      def self.expression
        %r{^http[s]?:\/\/datos.bne.es\/.*}
      end

      def self.label(data)
        data_bool = data.first['@graph'].first['label'].to_s.include?('@value')
        data_bool ? data.first['@graph'].first['label']['@value'] : data.first['@graph'].first['label']
      end

      def self.as_query(q)
        q.include?('.html') ? q.gsub('.html', '.jsonld') : q + '.jsonld'
      end
    end
  end
end
