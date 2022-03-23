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

    context 'with ubio term not in cache' do
      let(:statement) { RDF::Statement(RDF::URI('http://ubio.org/authority/metadata.php?lsid=urn:lsid:ubio.org:namebank:1187711'), RDF::Vocab::SKOS.prefLabel, 'pony') }

      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_return(nil)
        allow(OregonDigital::ControlledVocabularies::Vocabularies::Ubio).to receive(:fetch).and_return(statement)
      end

      it do
        expect(OregonDigital::ControlledVocabularies::Vocabularies::Ubio).to receive(:fetch)
        new_vocab.fetch
      end
    end

    context 'with ubio term in cache' do
      let(:graph) { RDF::Graph.new }

      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_return(graph)
      end

      it do
        expect(OregonDigital::ControlledVocabularies::Vocabularies::Ubio).not_to receive(:fetch)
        new_vocab.fetch
      end
>>>>>>> add in_triplestore check
    end
  end
end
