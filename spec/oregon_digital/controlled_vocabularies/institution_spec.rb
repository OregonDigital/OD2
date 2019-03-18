# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Institution do
  let(:vocab) { described_class }

  describe '#in_vocab?' do
    context 'when in vocab' do
      it { expect(vocab.in_vocab?('http://dbpedia.org/resource/Washington')).to be true }
    end
    context 'when not in vocab' do
      it { expect(vocab.in_vocab?('http://my.queryuri.com')).to be false }
    end
  end
  describe '#query_to_vocabulary' do
    context 'when in vocab' do
      it { expect(vocab.query_to_vocabulary('http://dbpedia.org/resource/Washington')).to be OregonDigital::ControlledVocabularies::Vocabularies::Dbpedia }
    end
    context 'when not in vocab' do
      it { expect(vocab.query_to_vocabulary('http://my.queryuri.com')).to be nil }
    end
  end
end
