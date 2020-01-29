# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::AccessRestrictions do
  let(:vocab) { described_class }

  describe '#in_vocab?' do
    context 'when in vocab' do
      it { expect(vocab.in_vocab?('http://opaquenamespace.org/ns/accessRestrictions/OSUrestricted')).to be true }
    end

    context 'when not in vocab' do
      it { expect(vocab.in_vocab?('http://my.queryuri.com')).to be false }
    end
  end

  describe '#query_to_vocabulary' do
    context 'when in vocab' do
      it { expect(vocab.query_to_vocabulary('http://opaquenamespace.org/ns/accessRestrictions/OSUrestricted')).to be OregonDigital::ControlledVocabularies::Vocabularies::OnsAccessRestrictions }
    end

    context 'when not in vocab' do
      it { expect(vocab.query_to_vocabulary('http://my.queryuri.com')).to be nil }
    end
  end
end
