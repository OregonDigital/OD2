# frozen_string_literal:true

RSpec.describe Qa::Authorities::Institution do
  let(:repository_instance) { described_class.new }
  let(:loc_names_request) { 'http://id.loc.gov/authorities/names/my_id.jsonld' }
  let(:ons_creator_request) { 'http://opaquenamespace.org/ns/creator/my_id.jsonld' }
  let(:loc_names_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/authorities/names/my_id' }.with_indifferent_access] }
  let(:ons_creator_response) { [{ 'rdfs:label': [{ '@language': 'en', '@value': 'mylabel' }], '@id': 'http://opaquenamespace.org/ns/creator/my_id' }.with_indifferent_access] }

  it { expect(repository_instance.label.call(loc_names_response, OregonDigital::ControlledVocabularies::Vocabularies::LocNames)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(ons_creator_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(repository_instance).to receive(:json).with(loc_names_request).and_return(loc_names_response)
      allow(repository_instance).to receive(:json).with(ons_creator_request).and_return(ons_creator_response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(repository_instance.search('http://id.loc.gov/authorities/names/my_id')).to eq [{ id: 'http://id.loc.gov/authorities/names/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/creator/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/creator/my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(repository_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
