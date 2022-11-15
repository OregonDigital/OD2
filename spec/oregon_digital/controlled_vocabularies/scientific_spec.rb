# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Scientific do
  let(:vocab) { described_class }
  let(:new_vocab) { described_class.new('https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=117268') }

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
    context 'when itis throws an error' do
      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_return(nil)
        allow(OregonDigital::ControlledVocabularies::Vocabularies::Itis).to receive(:fetch).and_raise(OregonDigital::ControlledVocabularies::ControlledVocabularyFetchError)
      end

      it { expect { new_vocab.fetch }.to raise_error OregonDigital::ControlledVocabularies::ControlledVocabularyFetchError }
    end

    context 'with itis term not in cache' do
      let(:statement) { RDF::Statement(RDF::URI('https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=117268'), RDF::Vocab::SKOS.prefLabel, 'pony') }

      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_return(nil)
        allow(OregonDigital::ControlledVocabularies::Vocabularies::Itis).to receive(:fetch).and_return(statement)
        allow_any_instance_of(TriplestoreAdapter::Client).to receive(:insert).and_return(true)
      end

      it do
        expect(OregonDigital::ControlledVocabularies::Vocabularies::Itis).to receive(:fetch)
        new_vocab.fetch
      end
    end

    context 'with itis term in cache' do
      let(:graph) { RDF::Graph.new }

      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_return(graph)
        allow(OregonDigital::Triplestore).to receive(:fetch).and_return(graph)
      end

      it do
        expect(OregonDigital::ControlledVocabularies::Vocabularies::Itis).not_to receive(:fetch)
        new_vocab.fetch
      end
    end
  end
end
