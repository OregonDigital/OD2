# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::SparMediaType do
  let(:vocab) { described_class }
  let(:data) { [{ 'http://www.w3.org/2000/01/rdf-schema#label': [{ '@value': 'blah' }.with_indifferent_access] }.with_indifferent_access] }
  let(:query) { 'www.blah.com/blah' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.label(data)).to eq 'blah' }
  it { expect(vocab.as_query(query)).to eq query }
end
