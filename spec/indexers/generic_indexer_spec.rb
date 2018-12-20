# frozen_string_literal:true

RSpec.describe GenericIndexer do
  let(:solr_doc) { {} }
  let(:attributes) { { title: at, dcmi_type: 'MyType' } }
  let(:at) { instance_double('ActiveTriples::Relation') }
  let(:dc) { described_class.new(Generic.new) }
  let(:dc_call) { dc.generate_solr_document }
  let(:gw) { instance_double('Generic') }

  context 'when #generate_solr_document is called' do
    before do
      # allow(dc).to receive(:generate_solr_document).and_return(solr_doc)
      allow(gw).to receive(:attributes).and_return(attributes)
      allow(at).to receive(:is_a?).and_return(true)
      allow(at).to receive(:to_a).and_return(['MyTitle'])
    end
    it 'calls the proper methods' do
      dc.generate_solr_document
      expect(dc).to receive(:index_value_for_singular).once
      # expect(described_class).to receive(:index_value_for_singular).once
    end
  end
end
