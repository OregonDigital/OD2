# frozen_string_literal:true

RSpec.describe DocumentIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:repository) { OregonDigital::ControlledVocabularies::Repository.new('http://opaquenamespace.org/ns/repository/my/repo') }
  let(:work) { Document.new(resource_type: 'http://purl.org/dc/dcmitype/Collection', repository: repository) }

  it { expect(solr_doc['type_label_tesim']).to eq 'Complex Object' }
end
