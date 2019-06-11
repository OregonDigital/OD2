# frozen_string_literal:true

RSpec.describe DocumentIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { create(:document) }

  it { expect(solr_doc.type_label).to eq 'MyType' }
end
