# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::Itis do
  let(:vocab) { described_class }
  let(:data) { { 'scientificName': { 'combinedName': 'blah' }.with_indifferent_access }.with_indifferent_access }
  let(:query) { 'http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=12345' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.label(data)).to eq 'blah' }
  it { expect(vocab.as_query(query)).to eq 'https://www.itis.gov/ITISWebService/jsonservice/getFullRecordFromTSN?tsn=12345' }
end

