# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Vocabularies::GettyUlan do
  let(:vocab) { described_class }
  let(:data) { [{ 'identified_by': [{ 'classified_as': [{ 'id': 'http://vocab.getty.edu/term/type/Descriptor' }], 'content': 'blah', 'language': [{ 'id': 'http://vocab.getty.edu/language/en' }] }], 'id': 'http://vocab.getty.edu/ulan/term_id' }.with_indifferent_access] }
  let(:query) { 'www.blah.com/blah' }

  it { expect(vocab.expression).to be_kind_of(Regexp) }
  it { expect(vocab.label(data)).to eq 'blah' }
  it { expect(vocab.as_query(query)).to eq query + '.json' }
end
