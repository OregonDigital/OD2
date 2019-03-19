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
    before do
      allow(new_vocab).to receive(:fetch).with(anything, anything)
      allow(described_class).to receive(rdf_subject).and_return('http://ubio.org/authority/metadata.php?lsid=urn:lsid:ubio.org:namebank:1187711')
    end
    context 'when in vocab' do
      it 'calls the proper method' do
        new_vocab.fetch('blah', 'blah')
        expect(new_vocab).to have_received(fetch_and_store).once
      end
    end
  end
end
