# frozen_string_literal:true

RSpec.describe GenericIndexer do
  let(:solr_doc) { {} }
  let(:attr) { { title: at, dcmi_type: 'MyType' }.with_indifferent_access }
  let(:at) { instance_double('ActiveTriples::Relation') }
  let(:dc) { described_class.new(gw) }
  let(:dc_call) { dc.generate_solr_document }
  let(:gw) { Generic.new }

  context 'when #generate_solr_document is called' do
    before do
      # allow(dc).to receive(:generate_solr_document).and_return(solr_doc)
      allow(gw).to receive(:attributes).and_return(attr)
      allow(at).to receive(:is_a?).and_return(true)
      allow(at).to receive(:to_a).and_return(['MyTitle'])
    end
    it 'calls the proper methods' do
      expect(dc_call).to eq 'MyTitle'
    end
  end
end
