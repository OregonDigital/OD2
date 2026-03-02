# frozen_string_literal:true

RSpec.describe OregonDigital::Triplestore do
  let(:triplestore) { described_class }
  let(:label) { 'Blah' }

  describe '#fetch' do
    before do
      stub_request(:get, 'http://opaquenamespace.org/ns/blah')
        .to_return(status: 200, body: '', headers: {})

      stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/blah%3E')
        .to_return(status: 200, body: '', headers: {})
    end

    it 'sets the triplestore as an instance of TriplestoreAdapter::Triplestore' do
      triplestore.fetch('http://opaquenamespace.org/ns/blah')
      expect(triplestore.instance_variable_get(:@triplestore)).to be_kind_of TriplestoreAdapter::Triplestore
    end
  end

  describe '#rdf_label_predicates' do
    it 'returns an array of predicates' do
      expect(triplestore.rdf_label_predicates).to be_kind_of Array
    end
    it 'returns the proper predicates' do
      expect(triplestore.rdf_label_predicates).to eq [RDF::Vocab::SKOS.prefLabel, RDF::Vocab::DC.title, RDF::Vocab::RDFS.label, RDF::Vocab::SKOS.altLabel, RDF::Vocab::SKOS.hiddenLabel]
    end
  end

  # TODO: re-enable
  describe '#predicate_labels' do
    xit 'returns an hash of labels' do
      expect(triplestore.predicate_labels(build_graph)).to eq('http://purl.org/dc/terms/title' => [],
                                                              'http://www.w3.org/2000/01/rdf-schema#label' => ['Blah'],
                                                              'http://www.w3.org/2004/02/skos/core#altLabel' => [],
                                                              'http://www.w3.org/2004/02/skos/core#hiddenLabel' => [],
                                                              'http://www.w3.org/2004/02/skos/core#prefLabel' => [])
    end
  end
end

def build_graph
  graph = RDF::Graph.new
  graph << RDF::Statement.new(RDF::URI.new('http://opaquenamespace.org/ns/TestVocabulary/TestTerm'), RDF::Vocab::RDFS.label, label)
  graph
end
