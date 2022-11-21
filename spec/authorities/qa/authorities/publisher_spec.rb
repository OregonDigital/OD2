# frozen_string_literal:true

RSpec.describe Qa::Authorities::Publisher do
  let(:publisher_instance) { described_class.new }
  let(:ons_request) { 'http://opaquenamespace.org/ns/publisher/my_id.jsonld' }
  let(:ons_creator_request) { 'http://opaquenamespace.org/ns/creator/my_id.jsonld' }
  let(:ulan_request) { 'http://vocab.getty.edu/ulan/my_id.jsonld' }
  let(:loc_names_request) { 'http://id.loc.gov/authorities/names/my_id.jsonld' }
  let(:ons_response) { [{ 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/publisher/my_id' }.with_indifferent_access] }
  let(:ons_creator_response) { [{ 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/creator/my_id' }.with_indifferent_access] }
  let(:ulan_response) { [{ 'identified_by': [{ 'classified_as': [{'id': 'http://vocab.getty.edu/term/type/Descriptor'}], 'content': 'mylabel' }], 'id': 'http://vocab.getty.edu/ulan/my_id' }.with_indifferent_access] }
  let(:loc_names_response) { [{ 'http://www.w3.org/2004/02/skos/core#prefLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/authorities/names/my_id' }.with_indifferent_access] }

  it { expect(publisher_instance.label.call(ons_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsPublisher)).to eq 'mylabel' }
  it { expect(publisher_instance.label.call(ulan_response, OregonDigital::ControlledVocabularies::Vocabularies::GettyUlan)).to eq 'mylabel' }
  it { expect(publisher_instance.label.call(loc_names_response, OregonDigital::ControlledVocabularies::Vocabularies::LocNames)).to eq 'mylabel' }
  it { expect(publisher_instance.label.call(ons_creator_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsCreator)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(publisher_instance).to receive(:json).with(ons_request).and_return(ons_response)
      allow(publisher_instance).to receive(:json).with(ons_creator_request).and_return(ons_creator_response)
      allow(publisher_instance).to receive(:json).with(ulan_request).and_return(ulan_response)
      allow(publisher_instance).to receive(:json).with(loc_names_request).and_return(loc_names_response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(publisher_instance.search('http://opaquenamespace.org/ns/publisher/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/publisher/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(publisher_instance.search('http://vocab.getty.edu/ulan/my_id')).to eq [{ id: 'http://vocab.getty.edu/ulan/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(publisher_instance.search('http://id.loc.gov/authorities/names/my_id')).to eq [{ id: 'http://id.loc.gov/authorities/names/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(publisher_instance.search('http://opaquenamespace.org/ns/creator/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/creator/my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(publisher_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
