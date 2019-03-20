# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::Dbpedia do
  let(:vocab) { described_class }
  let(:data) { [{ 'entity': { 'http://www.w3.org/2000/01/rdf-schema#label': [{ 'lang': 'en', 'value': 'blah' }] } }.with_indifferent_access] }
  let(:query) { 'www.blah.com/blah' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.label(data)).to eq 'blah' }
  it { expect(vocab.as_query(query)).to eq query }
end
