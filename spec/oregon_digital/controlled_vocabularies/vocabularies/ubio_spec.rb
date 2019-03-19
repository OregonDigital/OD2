# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::Ubio do
  let(:vocab) { described_class }
  let(:query) { 'www.blah.com/blah' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.as_query(query)).to eq query }
end

