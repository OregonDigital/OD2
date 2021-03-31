# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Institution do
  let(:vocab) { described_class }
  let(:vocab_inst) { described_class.new }

  describe '#in_vocab?' do
    context 'when in vocab' do
      it { expect(vocab.in_vocab?('http://id.loc.gov/authorities/names/n80126183')).to be true }
    end

    context 'when not in vocab' do
      it { expect(vocab.in_vocab?('http://my.queryuri.com')).to be false }
    end
  end

  describe '#query_to_vocabulary' do
    context 'when in vocab' do
      it { expect(vocab.query_to_vocabulary('http://id.loc.gov/authorities/names/n80126183')).to be OregonDigital::ControlledVocabularies::Vocabularies::LocNames }
    end

    context 'when not in vocab' do
      it { expect(vocab.query_to_vocabulary('http://my.queryuri.com')).to be nil }
    end
  end

  describe '#solrize' do
    context 'with a valid label and subject' do
      before do
        allow(vocab_inst).to receive(:rdf_label).and_return([RDF::Literal.new('RDF_Label', language: I18n.locale)])
        allow(vocab_inst).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end

      it { expect(vocab_inst.solrize).to eq ['RDF.Subject.Org', { label: 'RDF_Label$RDF.Subject.Org' }] }
    end

    context 'without a label' do
      before do
        allow(vocab_inst).to receive(:rdf_label).and_return([])
        allow(vocab_inst).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end

      it { expect(vocab_inst.solrize).to eq ['RDF.Subject.Org'] }
    end

    context 'when label and uri are the same' do
      before do
        allow(vocab_inst).to receive(:rdf_label).and_return([RDF::Literal.new('RDF.Subject.Org', language: I18n.locale)])
        allow(vocab_inst).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end

      it { expect(vocab_inst.solrize).to eq ['RDF.Subject.Org'] }
    end
  end
end
