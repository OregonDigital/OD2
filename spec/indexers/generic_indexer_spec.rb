# frozen_string_literal:true

RSpec.describe GenericIndexer do
  let(:solr_doc) { {} }
  let(:attributes) { { title: at, dcmi_type: 'MyType' } }
  let(:at) { instance_double('ActiveTriples::Relation') }

  context 'when #generate_solr_document is called' do
    before do
      allow(described_class).to receive(:generate_solr_document).and_return(solr_doc)
      allow(object).to receive(:attributes).and_return(attributes)
      allow(at).to receive(:is_a?).and_return(true)
      allow(at).to receive(:to_a).and_return(['MyTitle'])
    end
    it 'calls the proper methods' do
      expect(described_class).to receive(:index_value_for_multiple).once
      # expect(described_class).to receive(:index_value_for_singular).once
    end
    it 'sets the solr_doc with the right values' do
      expect(solr_doc['title']).to eq ['MyTitle']
      # expect(solr_doc['dcmi_type']).to eq ['MyType']
    end
  end
end
