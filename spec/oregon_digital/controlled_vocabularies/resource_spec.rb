# frozen_string_literal:true

RSpec.describe OregonDigital::ControlledVocabularies::Resource do
  let(:resource) { described_class.new }
  let(:new_rdf_graph) { RDF::Graph.new }
  let(:bg_graph) do
    graph = new_rdf_graph
    graph.name = RDF::URI('http://example/bg')
    graph
  end

  describe '#solrize' do
    context 'with a valid label and subject' do
      before do
        allow(resource).to receive(:rdf_label).and_return(['RDF_Label'])
        allow(resource).to receive(:rdf_subject).and_return('http://RDF.Subject.Org')
      end

      it { expect(resource.solrize).to eq ['https://RDF.Subject.Org', { label: 'RDF_Label$https://RDF.Subject.Org' }] }
    end

    context 'without a label' do
      before do
        allow(resource).to receive(:rdf_label).and_return([''])
        allow(resource).to receive(:rdf_subject).and_return('http://RDF.Subject.Org')
      end

      it { expect(resource.solrize).to eq ['http://RDF.Subject.Org'] }
    end

    context 'when label and uri are the same' do
      before do
        allow(resource).to receive(:rdf_label).and_return(['http://RDF.Subject.Org'])
        allow(resource).to receive(:rdf_subject).and_return('http://RDF.Subject.Org')
      end

      it { expect(resource.solrize).to eq ['http://RDF.Subject.Org'] }
    end
  end

  describe '#triplestore_fetch' do
    context 'when no rdf_subject is returned' do
      before do
        allow(resource).to receive(:rdf_subject).and_return('')
      end

      it { expect(resource.triplestore_fetch).to eq new_rdf_graph }
    end

    context 'when an rdf_subject is returned' do
      before do
        allow(resource).to receive(:rdf_subject).and_return('http://www.blah.com')
        allow(resource.triplestore).to receive(:fetch).with('http://www.blah.com').and_return(bg_graph)
      end

      it { expect(resource.triplestore_fetch).to eq bg_graph }
    end
  end

  describe '#set_subject!' do
    context 'with a term in the vocabulary' do
      before do
        allow(resource).to receive(:uri_in_vocab?).and_return(true)
      end

      it { expect { resource.set_subject!('http://my.queryuri.com') }.not_to raise_error(OregonDigital::ControlledVocabularies::ControlledVocabularyError) }
    end

    context 'with a term not in the vocabulary' do
      before do
        allow(resource).to receive(:uri_in_vocab?).and_return(false)
      end

      it { expect { resource.set_subject!('http://my.queryuri.com') }.to raise_error(OregonDigital::ControlledVocabularies::ControlledVocabularyError) }
    end
  end
end
