# frozen_string_literal:true

RSpec.describe 'Work show page', js: true, type: :system, clean_repo: true do
  let(:work) { create(:work, with_admin_set: true, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, rights_statement: ['http://rightsstatements.org/vocab/InC/1.0/'], creator: ['http://opaquenamespace.org/ns/creator/my_id'], description: ['description']) }

  before do
    stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/creator/my_id%3E').with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Host' => 'ci-test:8080', 'Keep-Alive' => '30', 'User-Agent' => 'Ruby' }).to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?>
      <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

      <rdf:Description rdf:about="http://opaquenamespace.org/ns/creator/UniversityofOregonstudents">
        <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#CorporateName"/>
        <rdf:type rdf:resource="http://www.w3.org/2000/01/rdf-schema#Resource"/>
        <comment xmlns="http://www.w3.org/2000/01/rdf-schema#" xml:lang="en">Professional contributors.</comment>
        <isDefinedBy xmlns="http://www.w3.org/2000/01/rdf-schema#" rdf:resource="http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt"/>
        <label xmlns="http://www.w3.org/2000/01/rdf-schema#" xml:lang="en">University of Oregon students</label>
        <seeAlso xmlns="http://www.w3.org/2000/01/rdf-schema#" rdf:resource="http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt"/>
        <issued xmlns="http://purl.org/dc/terms/" rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2015-07-16</issued>
        <issued xmlns="http://purl.org/dc/terms/" rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2015-08-25</issued>
        <modified xmlns="http://purl.org/dc/terms/" rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2015-07-16</modified>
        <modified xmlns="http://purl.org/dc/terms/" rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2015-08-25</modified>
      </rdf:Description>

      </rdf:RDF>', headers: {})
  end

  context 'with an annonymous user' do
    it 'is accessible' do
      visit "/concern/generics/#{work.id}"
      expect(page).to be_accessible
    end
  end

  context 'with a logged in user' do
    let(:user) { create(:user) }
    let!(:ability) { ::Ability.new(user) }
    let(:upload_file_path) { "#{Rails.root}/spec/fixtures/test.jpg" }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
      allow(CharacterizeJob).to receive(:perform_later)
      sign_in_as user
    end

    it 'is accessible' do
      visit "/concern/generics/#{work.id}"
      expect(page).to be_accessible
    end
  end
end
