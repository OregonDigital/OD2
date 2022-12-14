# frozen_string_literal:true

RSpec.describe Qa::Authorities::WorkType do
  let(:repository_instance) { described_class.new }
  let(:getty_request) { 'http://vocab.getty.edu/aat/my_id.json' }
  let(:ons_request) { 'http://opaquenamespace.org/ns/workType/my_id.jsonld' }
  let(:getty_response) { [{ 'identified_by': [{ 'classified_as': [{ 'id': 'http://vocab.getty.edu/term/type/Descriptor' }], 'content': 'mylabel', 'language': [{ 'id': 'http://vocab.getty.edu/language/en' }] }], 'id': 'http://vocab.getty.edu/aat/my_id' }.with_indifferent_access] }
  let(:ons_response) { [{ 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/workType/my_id' }.with_indifferent_access] }

  it { expect(repository_instance.label.call(getty_response, OregonDigital::ControlledVocabularies::Vocabularies::GettyAat)).to eq 'mylabel' }
  it { expect(repository_instance.label.call(ons_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsCulture)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(repository_instance).to receive(:json).with(getty_request).and_return(getty_response)
      allow(repository_instance).to receive(:json).with(ons_request).and_return(ons_response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(repository_instance.search('http://vocab.getty.edu/aat/my_id')).to eq [{ id: 'http://vocab.getty.edu/aat/my_id', label: 'mylabel' }.with_indifferent_access] }
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/workType/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/workType/my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(repository_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
