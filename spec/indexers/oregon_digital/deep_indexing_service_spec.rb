# frozen_string_literal: true

RSpec.describe OregonDigital::DeepIndexingService do
  subject(:service) { described_class.new(work) }

  let(:user) { build(:user) }
  let(:file_set) { FactoryBot.create(:file_set, user: user, title: ['Shark'], content: file) }
  let(:file) { File.open(fixture_path + '/test.jpg') }
  let(:work) { create(:image, title: ['Sharks on a plane'], location: [location], depositor: user.email, id: 'abcde1234', ordered_members: [file_set], representative_id: file_set.id) }
  let(:location) { Hyrax::ControlledVocabularies::Location.new('https://sws.geonames.org/5037649/') }

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
  end

  describe '#add_assertions' do
    it 'adds both property label and combined label' do
      solr_doc = service.send(:add_assertions, nil)
      expect(solr_doc['location_combined_label_sim']).to eq(['Newberg'])
      expect(solr_doc['location_label_sim']).to eq(['Newberg'])
    end

    context 'when a fetch fails' do
      let(:location) { Hyrax::ControlledVocabularies::Location.new('http://sws.geonames.org/5037650') }

      before do
        stub_request(:get, 'http://sws.geonames.org/5037650')
          .to_return(status: 500, body: '', headers: {})
        stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://sws.geonames.org/5037650').to_return(status: 500, body: '', headers: {})
      end

      it 'handles the error' do
        expect { location.fetch }.to raise_error(IOError)
        solr_doc = service.send(:add_assertions, nil)
        expect(solr_doc['location_combined_label_sim']).to eq nil
      end
    end
  end
end
