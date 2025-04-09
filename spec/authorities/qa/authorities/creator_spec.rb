# frozen_string_literal:true

RSpec.describe Qa::Authorities::Creator do
  let(:repository_instance) { described_class.new }
  let(:ons_creator_request) { 'http://opaquenamespace.org/ns/creator/my_id.jsonld' }
  let(:ons_people_request) { 'http://opaquenamespace.org/ns/people/my_id.jsonld' }
  let(:ons_osu_academic_units_request) { 'http://opaquenamespace.org/ns/osuAcademicUnits/my_id.jsonld' }
  let(:ulan_request) { 'http://vocab.getty.edu/ulan/my_id.json' }
  let(:loc_names_request) { 'http://id.loc.gov/authorities/names/my_id.jsonld' }
  let(:wikidata_request) { 'http://www.wikidata.org/entity/my_id' }
  let(:ons_creator_response) { [{ 'rdfs:label': [{ '@language': 'en', '@value': 'mylabel' }], '@id': 'http://opaquenamespace.org/ns/creator/my_id' }.with_indifferent_access] }
  let(:ons_people_response) { [{ 'rdfs:label': [{ '@language': 'en', '@value': 'mylabel' }], '@id': 'http://opaquenamespace.org/ns/people/my_id' }.with_indifferent_access] }
  let(:ons_osu_academic_units_response) { [{ 'rdfs:label': [{ '@language': 'en', '@value': 'mylabel' }], '@id': 'http://opaquenamespace.org/ns/osuAcademicUnits/my_id' }.with_indifferent_access] }
  let(:ulan_response) { [{ 'identified_by': [{ 'classified_as': [{ 'id': 'http://vocab.getty.edu/term/type/Descriptor' }], 'content': 'mylabel', 'language': [{ 'id': 'http://vocab.getty.edu/language/en' }] }], 'id': 'http://vocab.getty.edu/ulan/my_id' }.with_indifferent_access] }
  let(:loc_names_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/authorities/names/my_id' }.with_indifferent_access] }
  let(:wikidata_response) { [{ 'entities': { '123': { 'labels': { "#{I18n.locale}": { 'value': 'mylabel' } } } }, '@id': 'http://www.wikidata.org/entity/my_id' }.with_indifferent_access] }

  it { expect(repository_instance.label.call(ons_creator_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(ons_people_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsPeople)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(ons_osu_academic_units_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsOsuAcademicUnits)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(ulan_response, OregonDigital::ControlledVocabularies::Vocabularies::GettyUlan)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(loc_names_response, OregonDigital::ControlledVocabularies::Vocabularies::LocNames)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(wikidata_response, OregonDigital::ControlledVocabularies::Vocabularies::Wikidata)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(repository_instance).to receive(:json).with(ons_creator_request).and_return(ons_creator_response)
      allow(repository_instance).to receive(:json).with(ons_people_request).and_return(ons_people_response)
      allow(repository_instance).to receive(:json).with(ons_osu_academic_units_request).and_return(ons_osu_academic_units_response)
      allow(repository_instance).to receive(:json).with(ulan_request).and_return(ulan_response)
      allow(repository_instance).to receive(:json).with(loc_names_request).and_return(loc_names_response)
      allow(repository_instance).to receive(:json).with(wikidata_request).and_return(wikidata_response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/creator/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/creator/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/people/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/people/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/osuAcademicUnits/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/osuAcademicUnits/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://vocab.getty.edu/ulan/my_id')).to eq [{ id: 'http://vocab.getty.edu/ulan/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://id.loc.gov/authorities/names/my_id')).to eq [{ id: 'http://id.loc.gov/authorities/names/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://www.wikidata.org/entity/my_id')).to eq [{ id: 'http://www.wikidata.org/entity/my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(repository_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
