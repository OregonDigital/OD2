# frozen_string_literal:true

RSpec.describe AudioIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { build(:audio, resource_type: ['MyType']) }

  it { expect(solr_doc['resource_type_tesim']).to eq 'MyType' }
end
