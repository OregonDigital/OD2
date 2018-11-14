require 'rails_helper'

RSpec.describe OregonDigital::TriplePoweredProperties::WorkIndexer do
  let(:url) { 'http://opaquenamespace.org/ns/TestVocabulary/TestTerm' }
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:work) { DefaultWork.new({ based_near: [ url ], title: ['TestTest'] }) }
  let(:label) { 'hello' }

  describe "#generate_solr_document" do
    before do
      allow(work).to receive(:fetch).and_return(["Blahbalh"])
      allow(work).to receive(:uri_labels).and_return({:based_near => ["Blahblah"]})
    end
    it "Should append the labels into the solr_document" do
      expect(solr_document["based_near_tesim"]).to eq ["Blahblah"]
    end
  end
end