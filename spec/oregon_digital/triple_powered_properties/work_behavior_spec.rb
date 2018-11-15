require 'rails_helper'

RSpec.describe OregonDigital::TriplePoweredProperties::WorkBehavior do
  let(:url) { 'http://opaquenamespace.org/ns/TestVocabulary/TestTerm' }
  subject { Generic.new({ based_near: [ url ], title: ['TestTest'] }) }
  let(:label) { 'hello' }

  before do
    allow(subject).to receive(:uri_graphs).and_return({:based_near=>[{:uri=>url, :result=>build_graph}]})
  end

  describe '#uri_labels' do
    it 'should have triple powered properties with labels' do
      expect(subject.triple_powered_properties).to be_a_kind_of(Array)
      expect(subject.uri_labels(:based_near)[url]).to be_a_kind_of(Array)
      #TODO Check to see if we want this actually nested arrays... [[]]
      expect(subject.uri_labels(:based_near)[url].flatten).to include(label)
    end
  end
end

def build_graph
  graph = RDF::Graph.new
  graph << RDF::Statement.new(RDF::URI.new('http://opaquenamespace.org/ns/TestVocabulary/TestTerm'), RDF::Vocab::RDFS.label, label)
  graph
end