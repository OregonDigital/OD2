# frozen_string_literal: true

RSpec.describe OregonDigital::DeepIndexingService do
  subject(:service) { described_class.new(work) }

  let(:user) { build(:user) }
  let(:file) { File.open(fixture_path + '/test.jpg') }
  let(:work) { create(:image, title: ['Sharks on a plane'], location: [location], depositor: user.email, id: 'abcde1234', ordered_members: [file_set], representative_id: file_set.id) }
  let(:file_set) { create(:file_set, user: user, title: ['Shark'], content: file) }

  describe '#add_assertions' do
    context 'when there is a label to fetch' do
      let(:location) { Hyrax::ControlledVocabularies::Location.new('https://sws.geonames.org/5037649/') }
      let(:geo_subject) { RDF::URI('https://sws.geonames.org/5037649/') }
      let(:graph) do
        g = RDF::Graph.new
        g << RDF::Statement.new(geo_subject, RDF::URI('http://www.geonames.org/ontology#name'), 'Newberg')
        g << RDF::Statement.new(geo_subject, RDF::URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#type'), RDF::URI('http://www.geonames.org/ontology#Feature'))
        g
      end

      before do
        newberg = <<RDFXML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="no"?>
          <rdf:RDF xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gn="http://www.geonames.org/ontology#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
          <gn:Feature rdf:about="https://sws.geonames.org/5037649/">
          <rdfs:label>an RDFS Label</rdfs:label>
          <gn:name>Newberg</gn:name>
          </gn:Feature>
          </rdf:RDF>
RDFXML

        stub_request(:get, 'https://sws.geonames.org/5037649/')
          .to_return(status: 200, body: newberg,
                     headers: { 'Content-Type' => 'application/rdf+xml;charset=UTF-8' })
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_return(graph)
      end

      it 'adds both property label and combined label' do
        solr_doc = service.send(:add_assertions, nil)
        expect(solr_doc['location_combined_label_sim']).to eq(['Newberg'])
        expect(solr_doc['location_label_sim']).to eq(['Newberg'])
      end
    end

    context 'when a fetch fails' do
      let(:location) { Hyrax::ControlledVocabularies::Location.new('http://sws.geonames.org/5037650') }

      before do
        stub_request(:get, 'http://sws.geonames.org/5037650')
          .to_return(status: 500, body: '', headers: {})
        stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://sws.geonames.org/5037650%3E')
          .to_return(status: 500, body: '', headers: {})
      end

      it 'handles the error' do
        solr_doc = service.send(:add_assertions, nil)
        expect(solr_doc['location_combined_label_sim']).to eq nil
      end
    end
  end
end
