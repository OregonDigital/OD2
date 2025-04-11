# frozen_string_literal:true

RSpec.describe 'Work show page', js: true, type: :system, clean_repo: true do
  let(:work) { create(:work, with_admin_set: true, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, rights_statement: ['http://rightsstatements.org/vocab/InC/1.0/'], creator: [OregonDigital::ControlledVocabularies::Creator.new('http://opaquenamespace.org/ns/creator/my_id')], description: ['description']) }

  before do
    allow_any_instance_of(OregonDigital::ControlledVocabularies::Creator).to receive(:solrize).and_return(['http://opaquenamespace.org/ns/creator/my_id', { label: 'MyID$http://opaquenamespace.org/ns/creator/my_id' }])
    stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/creator/my_id%3E')
      .to_return(status: 200, body: '
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2004/02/skos/core#CorporateName> .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Resource> .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://www.w3.org/2000/01/rdf-schema#comment> "Professional contributors."@en .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt> .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://www.w3.org/2000/01/rdf-schema#label> "University of Oregon students"@en .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://www.w3.org/2000/01/rdf-schema#seeAlso> <http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt> .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://purl.org/dc/terms/issued> "2015-07-16"^^<http://www.w3.org/2001/XMLSchema#date> .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://purl.org/dc/terms/issued> "2015-08-25"^^<http://www.w3.org/2001/XMLSchema#date> .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://purl.org/dc/terms/modified> "2015-07-16"^^<http://www.w3.org/2001/XMLSchema#date> .
        <http://opaquenamespace.org/ns/creator/UniversityofOregonstudents> <http://purl.org/dc/terms/modified> "2015-08-25"^^<http://www.w3.org/2001/XMLSchema#date> .
      ', headers: {})
    stub_request(:get, 'http://opaquenamespace.org/ns/creator/my_id').with(
      headers: {
        'Accept' => 'application/n-triples, text/plain;q=0.2, application/ld+json, application/x-ld+json, application/rdf+xml, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, application/normalized+n-quads, application/x-normalized+n-quads, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig;q=0.2, application/trix, */*;q=0.1',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Ruby RDF.rb/3.2.11'
      }
    ).to_return(status: 200, body: '', headers: {})
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
