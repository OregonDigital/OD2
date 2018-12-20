# frozen_string_literal:true

RSpec.describe VideoIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { build(:video, resource_type: ['MyType']) }

  it { expect(solr_doc['dcmi_type_tesim']).to eq 'MyType' }
end
