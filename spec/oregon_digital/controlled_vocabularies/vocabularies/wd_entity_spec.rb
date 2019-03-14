# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::WdEntity do
  let(:vocab) { described_class }
  let(:data) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'blah', '@language': I18n.locale.to_s }.with_indifferent_access] }.with_indifferent_access] }
  let(:query) { 'www.blah.com/blah' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.label(data)).to eq 'blah' }
  it { expect(vocab.as_query(query)).to eq query }
end
