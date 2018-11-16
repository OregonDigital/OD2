require 'rails_helper'

RSpec.describe OregonDigital::TriplePoweredProperties::Triplestore do


  let(:triplestore) { described_class }
  let(:label) {"Blah"}

  describe "#fetch" do
    before do
      allow_any_instance_of(TriplestoreAdapter::Triplestore).to receive(:fetch).with("http://opaquenamespace.org/ns/blah", {:from_remote=>true}).and_return("blah")
    end
    it "should set the triplestore as an instance of TriplestoreAdapter::Triplestore" do
      triplestore.fetch("http://opaquenamespace.org/ns/blah")
      expect(triplestore.instance_variable_get(:@triplestore)).to be_kind_of TriplestoreAdapter::Triplestore
    end
  end

  describe "#rdf_label_predicates" do
    it "should return an array of predicates" do
      expect(triplestore.rdf_label_predicates).to be_kind_of Array
      expect(triplestore.rdf_label_predicates).to eq [RDF::Vocab::SKOS.prefLabel,
                                                      RDF::Vocab::DC.title,
                                                      RDF::Vocab::RDFS.label,
                                                      RDF::Vocab::SKOS.altLabel,
                                                      RDF::Vocab::SKOS.hiddenLabel]
    end
  end

  describe "#predicate_labels" do
    it "should return an hash of labels" do
      expect(triplestore.predicate_labels(build_graph)).to eq({"http://purl.org/dc/terms/title" => [],
                                                               "http://www.w3.org/2000/01/rdf-schema#label" => ["Blah"],
                                                               "http://www.w3.org/2004/02/skos/core#altLabel" => [],
                                                               "http://www.w3.org/2004/02/skos/core#hiddenLabel" => [],
                                                               "http://www.w3.org/2004/02/skos/core#prefLabel" => []})
    end
  end
end

def build_graph
  graph = RDF::Graph.new
  graph << RDF::Statement.new(RDF::URI.new('http://opaquenamespace.org/ns/TestVocabulary/TestTerm'), RDF::Vocab::RDFS.label, label)
  graph
end