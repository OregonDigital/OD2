# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::MediaType do
  let(:media_type) { described_class.new }

  describe '#solrize' do
    before do
      allow(media_type).to receive(:rdf_label).and_return(['RDF_Label'])
      allow(media_type).to receive(:rdf_subject).and_return('RDF.Subject.Org')
    end
    it { expect(media_type.solrize).to eq ['RDF.Subject.Org', { label: 'RDF_Label$RDF.Subject.Org' }] }
  end
end
