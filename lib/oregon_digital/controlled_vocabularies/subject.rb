# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Subject object for storing labels and uris
    class Subject < Resource
      def self.all_endpoints
        [
          OregonDigital::ControlledVocabularies::Vocabularies::GettyAat,
          OregonDigital::ControlledVocabularies::Vocabularies::Itis,
          OregonDigital::ControlledVocabularies::Vocabularies::LocGenreForms,
          OregonDigital::ControlledVocabularies::Vocabularies::LocGraphicMaterials,
          OregonDigital::ControlledVocabularies::Vocabularies::LocNames,
          OregonDigital::ControlledVocabularies::Vocabularies::LocOrgs,
          OregonDigital::ControlledVocabularies::Vocabularies::LocSubjects,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuAcademicUnits,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuBuildings,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsPeople,
          OregonDigital::ControlledVocabularies::Vocabularies::OnsSubject,
          OregonDigital::ControlledVocabularies::Vocabularies::Ubio,
          OregonDigital::ControlledVocabularies::Vocabularies::Ulan,
          OregonDigital::ControlledVocabularies::Vocabularies::WdEntity
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
        case vocabulary.to_s
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Itis'
          parse_json(vocabulary)
        when 'OregonDigital::ControlledVocabularies::Vocabularies::Ubio'
          parse_xml
        end
      end

       def parse_json(vocabulary)
        uri = vocabulary.as_query(rdf_subject.to_s)
        JSON.parse(Faraday.get(uri) { |req| req.headers['Accept'] = 'application/json' }.body)['scientificName']['combinedName']
      end

      def parse_xml
        Nokogiri::XML(Faraday.get(rdf_subject).body).at_xpath('/rdf:RDF/rdf:Description/dc:title/text()')
      end
    end
  end
end
