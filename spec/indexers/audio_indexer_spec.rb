# frozen_string_literal:true

RSpec.describe AudioIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { Audio.new(resource_type: 'MyType') }

  it { expect(solr_doc['type_label_tesim']).to eq 'MyType' }
end
