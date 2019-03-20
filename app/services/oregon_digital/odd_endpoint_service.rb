# frozen_string_literal: true

module OregonDigital
  class OddEndpointService

    private

    def self.statement(vocabulary, subject, label)
      RDF::Statement.new(subject, RDF::Vocab::SKOS.prefLabel, label)
    end
  end
end
