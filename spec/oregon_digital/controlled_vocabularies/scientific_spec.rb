# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Scientific do
  let(:vocab) { described_class }
  let(:new_vocab) { described_class.new('http://ubio.org/authority/metadata.php?lsid=urn:lsid:ubio.org:namebank:1187711') }

  describe '#in_vocab?' do
    context 'when in vocab' do
      it { expect(vocab.in_vocab?('http://opaquenamespace.org/ns/class/Ascidacea')).to be true }
    end

    context 'when not in vocab' do
      it { expect(vocab.in_vocab?('http://my.queryuri.com')).to be false }
    end
  end

  describe '#query_to_vocabulary' do
    context 'when in vocab' do
      it { expect(vocab.query_to_vocabulary('http://opaquenamespace.org/ns/class/Ascidacea')).to be OregonDigital::ControlledVocabularies::Vocabularies::OnsClass }
    end

    context 'when not in vocab' do
      it { expect(vocab.query_to_vocabulary('http://my.queryuri.com')).to be nil }
    end
  end

  describe '#fetch' do
    context 'when ubio throws an error' do
      before do
        allow(OregonDigital::ControlledVocabularies::Vocabularies::Ubio).to receive(:fetch).and_raise(OregonDigital::ControlledVocabularies::ControlledVocabularyFetchError)
      end

      it { expect { new_vocab.fetch }.to raise_error OregonDigital::ControlledVocabularies::ControlledVocabularyFetchError }
    end
  end
end
