# frozen_string_literal: true

RSpec.describe Hyrax::ControlledVocabularies::Location do
  let(:location) { described_class.new('https://sws.geonames.org/3469034/') }
  let(:parent_adm1) { described_class.new('https://sws.geonames.org/3469034/') }

  before do
    stub_request(:get, 'https://sws.geonames.org/3469034/')
      .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <rdf:RDF xmlns:cc="http://creativecommons.org/ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gn="http://www.geonames.org/ontology#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#">
          <gn:Feature rdf:about="https://sws.geonames.org/3469034/">
              <rdfs:isDefinedBy rdf:resource="https://sws.geonames.org/3469034/about.rdf"/>
              <gn:name>Brazil</gn:name>
              <gn:alternateName xml:lang="en">Federative Republic of Brazil</gn:alternateName>
              <gn:officialName xml:lang="en">Brazil</gn:officialName>
              <gn:featureClass rdf:resource="https://www.geonames.org/ontology#A"/>
              <gn:featureCode rdf:resource="https://www.geonames.org/ontology#A.PCLI"/>
              <gn:countryCode>BR</gn:countryCode>
              <gn:population>209469333</gn:population>
              <wgs84_pos:lat>-10</wgs84_pos:lat>
              <wgs84_pos:long>-55</wgs84_pos:long>
              <gn:parentFeature rdf:resource="https://sws.geonames.org/11812364/"/>
              <gn:parentFeature rdf:resource="https://sws.geonames.org/6255150/"/>
              <gn:childrenFeatures rdf:resource="https://sws.geonames.org/3469034/contains.rdf"/>
              <gn:neighbouringFeatures rdf:resource="https://sws.geonames.org/3469034/neighbours.rdf"/>
              <gn:locationMap rdf:resource="https://www.geonames.org/3469034/federative-republic-of-brazil.html"/>
              <gn:wikipediaArticle rdf:resource="https://en.wikipedia.org/wiki/Brazil"/>
              <rdfs:seeAlso rdf:resource="https://dbpedia.org/resource/Brazil"/>
              <gn:wikipediaArticle rdf:resource="https://ru.wikipedia.org/wiki/%D0%91%D1%80%D0%B0%D0%B7%D0%B8%D0%BB%D0%B8%D1%8F"/>
          </gn:Feature>
          <foaf:Document rdf:about="https://sws.geonames.org/3469034/about.rdf">
              <foaf:primaryTopic rdf:resource="https://sws.geonames.org/3469034/"/>
              <cc:license rdf:resource="https://creativecommons.org/licenses/by/4.0/"/>
              <cc:attributionURL rdf:resource="https://www.geonames.org"/>
              <cc:attributionName rdf:datatype="https://www.w3.org/2001/XMLSchema#string">GeoNames</cc:attributionName>
              <dcterms:created rdf:datatype="https://www.w3.org/2001/XMLSchema#date">2006-01-15</dcterms:created>
              <dcterms:modified rdf:datatype="https://www.w3.org/2001/XMLSchema#date">2020-03-29</dcterms:modified>
          </foaf:Document>
      </rdf:RDF>', headers: {})
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

      it { expect(location.rdf_label).to eq ['https://sws.geonames.org/3469034/'] }
    end

    context 'when a parent administrative hierarchy exists' do
      before do
        allow(location).to receive(:parent_hierarchy).and_return([[parent_adm1]])
        allow(location).to receive(:top_level_element?).and_return(true)
      end

      it { expect(location.rdf_label).to eq ['https://sws.geonames.org/3469034/'] }
    end

    context 'when a parent administrative hierarchy exists and isnt a top level element' do
      before do
        allow(location).to receive(:parent_hierarchy).and_return([[parent_adm1]])
        allow(location).to receive(:top_level_element?).and_return(false)
      end

      it { expect(location.rdf_label).to eq ['https://sws.geonames.org/3469034/'] }
    end
  end
end
