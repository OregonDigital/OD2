# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::MediaType do
  let(:vocab) { described_class }

  describe '#in_vocab?' do
    context 'when in vocab' do
      it { expect(vocab.in_vocab?('https://w3id.org/spar/mediatype/term/id')).to be true }
    end
    context 'when not in vocab' do
      it { expect(vocab.in_vocab?('http://my.queryuri.com')).to be false }
    end
  end
end
