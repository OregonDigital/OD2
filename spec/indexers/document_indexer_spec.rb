# frozen_string_literal:true

RSpec.describe DocumentIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { build(:document, resource_type: 'MyType') }

  it { expect(solr_doc['type_label_ssim']).to eq 'MyType' }
end
