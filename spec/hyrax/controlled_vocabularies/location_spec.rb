# frozen_string_literal: true

RSpec.describe Hyrax::ControlledVocabularies::Location do
  let(:location) { described_class.new('http://dbpedia.org/resource/Oregon_State_University') }
  let(:parent_feature) { described_class.new('http://dbpedia.org/resource/Oregon_State_University') }

  before do
    stub_request(:get, 'http://dbpedia.org/resource/Oregon_State_University')
      .to_return(status: 200, body: '', headers: {})
  end

  describe '#solrize' do
    context 'with a valid label and subject' do
      before do
        allow(location).to receive(:rdf_label).and_return(['RDF_Label'])
        allow(location).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end

      it { expect(location.solrize).to eq ['RDF.Subject.Org', { label: 'RDF_Label$RDF.Subject.Org' }] }
    end

    context 'without a label' do
      before do
        allow(location).to receive(:rdf_label).and_return([''])
        allow(location).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end

      it { expect(location.solrize).to eq ['RDF.Subject.Org'] }
    end

    context 'when label and uri are the same' do
      before do
        allow(location).to receive(:rdf_label).and_return(['RDF.Subject.Org'])
        allow(location).to receive(:rdf_subject).and_return('RDF.Subject.Org')
      end

      it { expect(location.solrize).to eq ['RDF.Subject.Org'] }
    end
  end

  describe '#fetch' do
    context 'when a top level element is found' do
      before do
        allow(location).to receive(:top_level_element?).and_return(true)
      end

      it { expect(location.fetch).to eq location }
    end

    context 'when a top level element is not found' do
      before do
        allow(location).to receive(:top_level_element?).and_return(false)
        allow(location).to receive(:parentFeature).and_return(parent_feature)
        allow(parent_feature).to receive(:fetch).and_return(parent_feature)
      end

      it { expect(location.fetch).to eq parent_feature }
    end
  end

  describe '#persist!' do
    context 'when a top level element is found' do
      before do
        allow(location).to receive(:top_level_element?).and_return(true)
      end

      it { expect(location.persist!).to eq true }
    end

    context 'when a top level element is not found' do
      before do
        allow(location).to receive(:top_level_element?).and_return(false)
        allow(location).to receive(:parentFeature).and_return(parent_feature)
        allow(parent_feature).to receive(:persist!).and_return(parent_feature)
      end

      it { expect(location.fetch).to eq location }
    end
  end

  describe '#rdf_label' do
    context 'when no parent feature exists' do
      before do
        allow(location).to receive(:parentFeature).and_return([])
      end

      it { expect(location.rdf_label).to eq ['http://dbpedia.org/resource/Oregon_State_University'] }
    end

    context 'when a parent feature exists' do
      before do
        allow(location).to receive(:parentFeature).and_return(parent_feature)
        allow(location).to receive(:top_level_element?).and_return(true)
        allow(location).to receive(:valid_label_without_parent).and_return(false)
      end

      it { expect(location.rdf_label).to eq ['http://dbpedia.org/resource/Oregon_State_University'] }
    end

    context 'when a parent feature exists and isnt a top level element' do
      before do
        allow(location).to receive(:parentFeature).and_return(parent_feature)
        allow(location).to receive(:top_level_element?).and_return(false)
        allow(location).to receive(:valid_label_without_parent).and_return(false)
        allow(location).to receive(:label_or_blank).and_return('Parent Label')
        allow(location).to receive(:top_level_parent).with('Parent Label').and_return(true)
      end

      it { expect(location.rdf_label).to eq ['http://dbpedia.org/resource/Oregon_State_University'] }
    end

    context 'when a parent feature exists and is a top level element with a feature class' do
      before do
        allow(location).to receive(:parentFeature).and_return(parent_feature)
        allow(location).to receive(:top_level_element?).and_return(false)
        allow(location).to receive(:valid_label_without_parent).and_return(false)
        allow(location).to receive(:label_or_blank).and_return('Parent Label')
        allow(location).to receive(:top_level_parent).with('Parent Label').and_return(false)
        allow(location).to receive(:featureClass).and_return([described_class.new('https://www.geonames.org/ontology#A')])
      end

      it { expect(location.rdf_label).to eq ['http://dbpedia.org/resource/Oregon_State_University, Parent Label, (Administrative Boundary)'] }
    end
  end
end
