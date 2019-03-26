# frozen_string_literal:true

RSpec.describe OregonDigital::Triplestore do
  let(:triplestore) { described_class }
  let(:label) { 'Blah' }
  let(:user) { build(:user) }

  describe '#fetch' do
    before do
      stub_request(:get, 'http://opaquenamespace.org/ns/blah')
        .to_return(status: 200, body: '', headers: {})

      stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/blah%3E')
        .to_return(status: 200, body: '', headers: {})
    end

    it 'sets the triplestore as an instance of TriplestoreAdapter::Triplestore' do
      triplestore.fetch('http://opaquenamespace.org/ns/blah', :user)
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

  describe '#predicate_labels' do
    it 'returns an hash of labels' do
      expect(triplestore.predicate_labels(build_graph)).to eq('http://purl.org/dc/terms/title' => [],
                                                              'http://www.w3.org/2000/01/rdf-schema#label' => ['Blah'],
                                                              'http://www.w3.org/2004/02/skos/core#altLabel' => [],
                                                              'http://www.w3.org/2004/02/skos/core#hiddenLabel' => [],
                                                              'http://www.w3.org/2004/02/skos/core#prefLabel' => [])
    end
  end

  describe '#enqueue_fetch_failure' do
    before do
      allow(Hyrax.config.callback).to receive(:run)
      allow(FetchGraphWorker).to receive(:perform_in)
      stub_request(:post, 'http://ci-test:8080/bigdata/namespace/rw/sparql')
        .to_return(status: 200, body: '', headers: {})
    end
    it 'emails the user' do
      expect(Hyrax.config.callback).to receive(:run).with(:ld_fetch_error, :user, :uri)
      triplestore.enqueue_fetch_failure(:uri, :user)
    end
    it 'enqueues a retry job' do
      expect(FetchGraphWorker).to receive(:perform_in).with(15.minutes, :uri, :user)
      triplestore.enqueue_fetch_failure(:uri, :user)
    end
    it 'stubs data in the triplestore' do
      expect(triplestore.instance_variable_get(:@triplestore)).to receive(:store)
      triplestore.enqueue_fetch_failure(:uri, :user)
    end
  end
end

def build_graph
  graph = RDF::Graph.new
  graph << RDF::Statement.new(RDF::URI.new('http://opaquenamespace.org/ns/TestVocabulary/TestTerm'), RDF::Vocab::RDFS.label, label)
  graph
end
