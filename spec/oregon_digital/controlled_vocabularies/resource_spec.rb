# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Resource do
  let(:resource) { described_class.new }

  describe '#solrize' do
    context 'with a valid label and subject' do
      before do
        allow(resource).to receive(:rdf_label).and_return(['RDF_Label'])
        allow(resource).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end
      it { expect(resource.solrize).to eq ['RDF.Subject.Org', { label: 'RDF_Label$RDF.Subject.Org' }] }
    end
    context 'without a label' do
      before do
        allow(resource).to receive(:rdf_label).and_return([''])
        allow(resource).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end
      it { expect(resource.solrize).to eq ['RDF.Subject.Org'] }
    end
    context 'when label and uri are the same' do
      before do
        allow(resource).to receive(:rdf_label).and_return(['RDF.Subject.Org'])
        allow(resource).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end
      it { expect(resource.solrize).to eq ['RDF.Subject.Org'] }
    end
  end
end
