# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::LocEthnographicTerms do
  let(:vocab) { described_class }
  let(:data) { [{ 'http://www.loc.gov/mads/rdf/v1#authoritativeLabel': [{ '@value': 'blah' }.with_indifferent_access] }.with_indifferent_access] }
  let(:query) { 'www.blah.com/blah' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.label(data)).to eq 'blah' }
  it { expect(vocab.as_query(query)).to eq query + '.jsonld' }
end
