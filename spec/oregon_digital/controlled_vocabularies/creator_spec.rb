# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Creator do
  let(:vocab) { described_class }

  describe '#in_vocab?' do
    context 'when in vocab' do
      it { expect(vocab.in_vocab?('http://vocab.getty.edu/ulan/500302766')).to be true }
    end

    context 'when not in vocab' do
      it { expect(vocab.in_vocab?('http://my.queryuri.com')).to be false }
    end
  end

  describe '#query_to_vocabulary' do
    context 'when in vocab' do
      it { expect(vocab.query_to_vocabulary('http://vocab.getty.edu/ulan/500302766')).to be OregonDigital::ControlledVocabularies::Vocabularies::GettyUlan }
    end

    context 'when not in vocab' do
      it { expect(vocab.query_to_vocabulary('http://my.queryuri.com')).to be nil }
    end
  end
end
