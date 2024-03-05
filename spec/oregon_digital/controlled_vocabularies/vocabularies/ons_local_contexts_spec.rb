# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::OnsLocalContexts do
  let(:vocab) { described_class }
  let(:data) { [{ 'rdfs:label': { '@value': 'blah' }.with_indifferent_access }.with_indifferent_access] }
  let(:query) { 'www.blah.com/blah' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.label(data)).to eq 'blah' }
  it { expect(vocab.as_query(query)).to eq query + '.jsonld' }
end
