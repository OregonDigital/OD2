# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Repository object for storing labels and uris
    class Scientific < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::OnsGenus,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsPhylum,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCommonNames,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsClass,
          OregonDigital::ControlledVocabularies::Vocabularies::WdEntity,
          OregonDigital::ControlledVocabularies::Vocabularies::Itis,
          OregonDigital::ControlledVocabularies::Vocabularies::Ubio
        ]
      end

      def fetch(*_args, &_block)
        case self.class.query_to_vocabulary(rdf_subject.to_s)
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Itis'
          fetch_and_store
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Ubio'
          fetch_and_store
        else
          super
        end
      end

      private

      def fetch_and_store
        new_statement = statement
        OregonDigital::Triplestore.triplestore_client.insert([new_statement])
        self << statement
      end

      def statement
        RDF::Statement.new(rdf_subject, RDF::Vocab::SKOS.prefLabel, subject_label)
      end

      def subject_label
        vocabulary = self.class.query_to_vocabulary(rdf_subject.to_s)
        case vocabulary.to_s
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Itis'
          parse_json   
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Ubio'
          parse_xml
        end
      end

      def parse_json
        uri = vocabulary.as_query(rdf_subject.to_s)
        JSON.parse(Faraday.get(uri) { |req| req.headers['Accept'] = 'application/json' }.body)['scientificName']['combinedName']
      end

      def parse_xml
        Nokogiri::XML(Faraday.get(rdf_subject).body).at_xpath('/rdf:RDF/rdf:Description/dc:title/text()')
      end
    end
  end
end
