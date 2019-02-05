# frozen_string_literal: true

RSpec.describe Hyrax::ControlledVocabularies::Location do
  let(:location) { described_class.new("http://dbpedia.org/resource/Oregon_State_University") }
  let(:args) { double("args") }
  let(:block) { double("block") }

  before do
    stub_request(:get, "http://dbpedia.org/resource/Oregon_State_University")
      .to_return(status: 200, body: "", headers: {})
  end

  describe '#solrize' do
    before do
      allow(location).to receive(:rdf_label).and_return(['RDF_Label'])
      allow(location).to receive(:rdf_subject).and_return('RDF.Subject.Org')
    end
    it { expect(location.solrize).to eq ['RDF.Subject.Org', { label: 'RDF_Label$RDF.Subject.Org' }] }
  end

  describe '#fetch' do
    context "when a top level element is found" do
      before do
        allow(location).to receive(:top_level_element?).and_return(true)
      end
      it { expect(location.fetch).to eq location }
    end
  end
end