# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::HistoricPlace do
  let(:vocab) { described_class }

  describe '#in_vocab?' do
    context 'when in vocab' do
      it { expect(vocab.in_vocab?('http://vocab.getty.edu/tgn/term_id')).to be true }
    end
    context 'when not in vocab' do
      it { expect(vocab.in_vocab?('http://my.queryuri.com')).to be false }
    end
  end
end
