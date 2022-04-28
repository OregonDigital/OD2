# frozen_string_literal: true

RSpec.describe OregonDigital::DeepIndexingService do
  subject(:service) { described_class.new(work) }

  let(:user) { build(:user) }
  let(:file_set) { FactoryBot.create(:file_set, user: user, title: ['Shark'], content: file) }
  let(:file) { File.open(fixture_path + '/test.jpg') }
  let(:work) { create(:image, title: ['Sharks on a plane'], location: [location], depositor: user.email, id: 'abcde1234', ordered_members: [file_set], representative_id: file_set.id) }
  let(:location) { Hyrax::ControlledVocabularies::Location.new('http://sws.geonames.org/5037649/') }

  before do
    newberg = <<RDFXML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
          <rdf:RDF xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gn="http://www.geonames.org/ontology#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
          <gn:Feature rdf:about="http://sws.geonames.org/5037649/">
          <rdfs:label>an RDFS Label</gn:name>
          <gn:name>Newberg</gn:name>
          </gn:Feature>
          </rdf:RDF>
RDFXML

    stub_request(:get, 'http://sws.geonames.org/5037649/')
      .to_return(status: 200, body: newberg,
                 headers: { 'Content-Type' => 'application/rdf+xml;charset=UTF-8' })
  end

  describe '#add_assertions' do
    it 'adds both property label and combined label' do
      solr_doc = service.send(:add_assertions, nil)
      expect(solr_doc['location_combined_label_sim']).to eq(['Newberg'])
      expect(solr_doc['location_label_sim']).to eq(['Newberg'])
    end
  end
end
