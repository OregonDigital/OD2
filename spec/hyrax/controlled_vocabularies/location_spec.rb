# frozen_string_literal: true

RSpec.describe Hyrax::ControlledVocabularies::Location do
  let(:location) { described_class.new('http://dbpedia.org/resource/Oregon_State_University') }
  let(:parent_adm1) { described_class.new('http://dbpedia.org/resource/Oregon_State_University') }

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
        allow(location).to receive(:parent_hierarchy).and_return([[parent_adm1]])
        allow(parent_adm1).to receive(:fetch).and_return(parent_adm1)
      end

      it { expect(location.fetch).to eq location }
      it do
        expect(parent_adm1).to receive(:fetch).once
        location.fetch
      end
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
        allow(location).to receive(:parent_hierarchy).and_return([[parent_adm1]])
        allow(parent_adm1).to receive(:persist!).and_return(parent_adm1)
      end

      it { expect(location.persist!).to eq true }
      it do
        expect(parent_adm1).to receive(:persist!).once
        location.persist!
      end
    end
  end

  describe '#rdf_label' do
    context 'when no parent administrative hierarchy exists' do
      before do
        allow(location).to receive(:parent_hierarchy).and_return([])
      end

      it { expect(location.rdf_label).to eq ['http://dbpedia.org/resource/Oregon_State_University'] }
    end

    context 'when a parent administrative hierarchy exists' do
      before do
        allow(location).to receive(:parent_hierarchy).and_return([[parent_adm1]])
        allow(location).to receive(:top_level_element?).and_return(true)
      end

      it { expect(location.rdf_label).to eq ['http://dbpedia.org/resource/Oregon_State_University'] }
    end

    context 'when a parent administrative hierarchy exists and isnt a top level element' do
      before do
        allow(location).to receive(:parent_hierarchy).and_return([[parent_adm1]])
        allow(location).to receive(:top_level_element?).and_return(false)
      end

      it { expect(location.rdf_label).to eq ['http://dbpedia.org/resource/Oregon_State_University'] }
    end
  end
end
