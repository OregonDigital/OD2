# frozen_string_literal:true

RSpec.describe GenericIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { Generic.new(resource_type: 'MyType') }

  it { expect(solr_doc['type_label_tesim']).to eq 'MyType' }
  it { expect(solr_doc['license_tesim']).to eq ['MyLicense'] }
  it { expect(solr_doc['language_tesim']).to eq ['MyLanguage'] }
  it { expect(solr_doc['rights_statement_tesim']).to eq ['MyRights'] }
end
