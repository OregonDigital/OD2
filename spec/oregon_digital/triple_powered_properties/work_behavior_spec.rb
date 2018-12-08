# frozen_string_literal:true

RSpec.describe OregonDigital::TriplePoweredProperties::WorkBehavior do
  let(:url) { 'http://opaquenamespace.org/ns/TestVocabulary/TestTerm' }
  let(:work) { Generic.new(based_near: [url], title: ['TestTest']) }
  let(:label) { 'hello' }

  before do
    allow(work).to receive(:uri_graphs).and_return(based_near: [{ uri: url, result: build_graph }])
  end

  describe '#uri_labels' do
    it 'has an array of triple powered properties' do
      expect(work.triple_powered_properties).to be_a_kind_of(Array)
    end
    it 'has a triple powered property with an array of labels' do
      expect(work.uri_labels(:based_near)[url]).to be_a_kind_of(Array)
    end
    # TODO: Check to see if we want this actually nested arrays... [[]]
    it 'has a triple powered property with a flat array' do
      expect(work.uri_labels(:based_near)[url].flatten).to include(label)
    end
  end
end

def build_graph
  graph = RDF::Graph.new
  graph << RDF::Statement.new(RDF::URI.new('http://opaquenamespace.org/ns/TestVocabulary/TestTerm'), RDF::Vocab::RDFS.label, label)
  graph
end
