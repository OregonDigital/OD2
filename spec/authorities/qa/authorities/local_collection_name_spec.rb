# frozen_string_literal:true

RSpec.describe Qa::Authorities::LocalCollectionName do
  let(:local_collection_name_instance) { described_class.new }
  let(:response) { [{ 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'my_id' }.with_indifferent_access] }

  it { expect(local_collection_name_instance.label.call(response, OregonDigital::ControlledVocabularies::Vocabularies::OnsLocalCollectionName)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(local_collection_name_instance).to receive(:json).with(anything).and_return(response)
      allow(local_collection_name_instance).to receive(:find_term).with(anything, anything).and_return(response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(local_collection_name_instance.search('http://opaquenamespace.org/ns/localCollectionName/term_id')).to eq [{ id: 'my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(local_collection_name_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
