# frozen_string_literal:true

RSpec.describe ImageIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { build(:image, resource_type: ['MyType']) }

  it { expect(solr_doc['dcmi_type_tesim']).to eq ['MyType'] }
end
