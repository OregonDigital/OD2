# frozen_string_literal:true

RSpec.describe GenericIndexer do
  let(:solr_doc) { {} }
  let(:attributes) { { title: at, dcmi_type: 'MyType' } }
  let(:at) { instance_double('ActiveTriples::Relation') }
  let(:dc) { described_class.new(solr_doc) }
  let(:dc_call) { dc.generate_solr_document }

  context 'when #generate_solr_document is called' do
    before do
      allow(dc).to receive(:generate_solr_document).and_return(solr_doc)
      allow(solr_doc).to receive(:attributes).and_return(attributes)
      allow(at).to receive(:is_a?).and_return(true)
      allow(at).to receive(:to_a).and_return(['MyTitle'])
    end
    it 'calls the proper methods' do
      expect(dc_call).to receive(:index_value_for_multiple).once
      # expect(described_class).to receive(:index_value_for_singular).once
    end
  end
end
