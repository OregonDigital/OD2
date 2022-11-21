# frozen_string_literal:true

RSpec.describe Qa::Authorities::Subject do
  let(:repository_instance) { described_class.new }
  let(:getty_request) { 'http://vocab.getty.edu/aat/my_id.jsonld' }
  let(:loc_genre_forms_request) { 'http://id.loc.gov/authorities/genreForms/my_id.jsonld' }
  let(:loc_graphic_materials_request) { 'http://id.loc.gov/vocabulary/graphicMaterials/my_id.jsonld' }
  let(:loc_names_request) { 'http://id.loc.gov/authorities/names/my_id.jsonld' }
  let(:loc_orgs_request) { 'http://id.loc.gov/vocabulary/organizations/my_id.jsonld' }
  let(:loc_subjects_request) { 'http://id.loc.gov/authorities/subjects/my_id.jsonld' }
  let(:ons_creator_request) { 'http://opaquenamespace.org/ns/creator/my_id.jsonld' }
  let(:ons_osu_academic_units_request) { 'http://opaquenamespace.org/ns/osuAcademicUnits/my_id.jsonld' }
  let(:ons_osu_buildings_request) { 'http://opaquenamespace.org/ns/osuBuildings/my_id.jsonld' }
  let(:ons_people_request) { 'http://opaquenamespace.org/ns/people/my_id.jsonld' }
  let(:ons_subject_request) { 'http://opaquenamespace.org/ns/subject/my_id.jsonld' }
  let(:ulan_request) { 'http://vocab.getty.edu/ulan/my_id.jsonld' }
  let(:wikidata_request) { 'http://www.wikidata.org/entity/my_id' }
  let(:getty_response) { [{ 'http://www.w3.org/2000/01/rdf-schema#label': [{ '@value': 'mylabel' }], '@id': 'http://vocab.getty.edu/aat/my_id' }.with_indifferent_access] }
  let(:loc_genre_forms_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/authorities/genreForms/my_id' }.with_indifferent_access] }
  let(:loc_graphic_materials_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/vocabulary/graphicMaterials/my_id' }.with_indifferent_access] }
  let(:loc_names_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/authorities/names/my_id' }.with_indifferent_access] }
  let(:loc_orgs_response) { [{ 'http://www.loc.gov/mads/rdf/v1#authoritativeLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/vocabulary/organizations/my_id' }.with_indifferent_access] }
  let(:loc_subjects_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/authorities/subjects/my_id' }.with_indifferent_access] }
  let(:ons_creator_response) { { 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/creator/my_id' }.with_indifferent_access }
  let(:ons_osu_academic_units_response) { { 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/osuAcademicUnits/my_id' }.with_indifferent_access }
  let(:ons_osu_buildings_response) { { 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/osuBuildings/my_id' }.with_indifferent_access }
  let(:ons_people_response) { { 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/people/my_id' }.with_indifferent_access }
  let(:ons_subject_response) { { 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/subject/my_id' }.with_indifferent_access }
  let(:ulan_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://vocab.getty.edu/ulan/my_id' }.with_indifferent_access] }
  let(:wikidata_response) { [{ 'entities': { '123': { 'labels': { "#{I18n.locale}": { 'value': 'mylabel' } } } }, '@id': 'http://www.wikidata.org/entity/my_id' }.with_indifferent_access] }

  it { expect(repository_instance.label.call(getty_response, OregonDigital::ControlledVocabularies::Vocabularies::GettyAat)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(loc_genre_forms_response, OregonDigital::ControlledVocabularies::Vocabularies::LocGenreForms)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(loc_graphic_materials_response, OregonDigital::ControlledVocabularies::Vocabularies::LocGraphicMaterials)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(loc_names_response, OregonDigital::ControlledVocabularies::Vocabularies::LocNames)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(loc_orgs_response, OregonDigital::ControlledVocabularies::Vocabularies::LocOrgs)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(loc_subjects_response, OregonDigital::ControlledVocabularies::Vocabularies::LocSubjects)).to eq 'mylabel' }
  it { expect(repository_instance.label.call([ons_creator_response], OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator)).to eq 'mylabel' }
  it { expect(repository_instance.label.call([ons_osu_academic_units_response], OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuAcademicUnits)).to eq 'mylabel' }
  it { expect(repository_instance.label.call([ons_osu_buildings_response], OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuBuildings)).to eq 'mylabel' }
  it { expect(repository_instance.label.call([ons_people_response], OregonDigital::ControlledVocabularies::Vocabularies::OnsPeople)).to eq 'mylabel' }
  it { expect(repository_instance.label.call([ons_subject_response], OregonDigital::ControlledVocabularies::Vocabularies::OnsSubject)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(ulan_response, OregonDigital::ControlledVocabularies::Vocabularies::GettyUlan)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(wikidata_response, OregonDigital::ControlledVocabularies::Vocabularies::Wikidata)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(repository_instance).to receive(:json).with(getty_request).and_return(getty_response)
      allow(repository_instance).to receive(:json).with(loc_genre_forms_request).and_return(loc_genre_forms_response)
      allow(repository_instance).to receive(:json).with(loc_graphic_materials_request).and_return(loc_graphic_materials_response)
      allow(repository_instance).to receive(:json).with(loc_names_request).and_return(loc_names_response)
      allow(repository_instance).to receive(:json).with(loc_orgs_request).and_return(loc_orgs_response)
      allow(repository_instance).to receive(:json).with(loc_subjects_request).and_return(loc_subjects_response)
      allow(repository_instance).to receive(:json).with(ons_creator_request).and_return([ons_creator_response])
      allow(repository_instance).to receive(:json).with(ons_osu_academic_units_request).and_return([ons_osu_academic_units_response])
      allow(repository_instance).to receive(:json).with(ons_osu_buildings_request).and_return([ons_osu_buildings_response])
      allow(repository_instance).to receive(:json).with(ons_people_request).and_return([ons_people_response])
      allow(repository_instance).to receive(:json).with(ons_subject_request).and_return([ons_subject_response])
      allow(repository_instance).to receive(:json).with(ulan_request).and_return(ulan_response)
      allow(repository_instance).to receive(:json).with(wikidata_request).and_return(wikidata_response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(repository_instance.search('http://vocab.getty.edu/aat/my_id')).to eq [{ id: 'http://vocab.getty.edu/aat/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://id.loc.gov/authorities/genreForms/my_id')).to eq [{ id: 'http://id.loc.gov/authorities/genreForms/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://id.loc.gov/vocabulary/graphicMaterials/my_id')).to eq [{ id: 'http://id.loc.gov/vocabulary/graphicMaterials/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://id.loc.gov/authorities/names/my_id')).to eq [{ id: 'http://id.loc.gov/authorities/names/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://id.loc.gov/vocabulary/organizations/my_id')).to eq [{ id: 'http://id.loc.gov/vocabulary/organizations/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://id.loc.gov/authorities/subjects/my_id')).to eq [{ id: 'http://id.loc.gov/authorities/subjects/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/creator/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/creator/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/osuAcademicUnits/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/osuAcademicUnits/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/osuBuildings/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/osuBuildings/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/people/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/people/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/subject/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/subject/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://vocab.getty.edu/ulan/my_id')).to eq [{ id: 'http://vocab.getty.edu/ulan/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://www.wikidata.org/entity/my_id')).to eq [{ id: 'http://www.wikidata.org/entity/my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(repository_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
