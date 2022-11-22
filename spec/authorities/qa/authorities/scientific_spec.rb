# frozen_string_literal:true

RSpec.describe Qa::Authorities::Scientific do
  let(:repository_instance) { described_class.new }
  let(:ons_request) { 'http://opaquenamespace.org/ns/class/my_id.jsonld' }
  let(:ons_response) { [{ 'rdfs:label': { '@value': 'mylabel' }.with_indifferent_access, '@id': 'http://opaquenamespace.org/ns/class/my_id' }.with_indifferent_access] }

  it { expect(repository_instance.label.call(ons_response, OregonDigital::ControlledVocabularies::Vocabularies::OnsStylePeriod)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(repository_instance).to receive(:json).with(ons_request).and_return(ons_response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(repository_instance.search('http://opaquenamespace.org/ns/class/my_id')).to eq [{ id: 'http://opaquenamespace.org/ns/class/my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(repository_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
