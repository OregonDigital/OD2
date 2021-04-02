# frozen_string_literal:true

RSpec.describe VideoIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { Video.new(resource_type: 'http://purl.org/dc/dcmitype/Collection') }

  it { expect(solr_doc['resource_type_label_tesim']).to eq 'Complex Object' }
end
