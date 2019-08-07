# frozen_string_literal:true

RSpec.describe Qa::Authorities::Format do
  let(:format_instance) { described_class.new }
  let(:response) { [{ 'http://www.w3.org/2000/01/rdf-schema#label': [{ '@value': 'mylabel' }.with_indifferent_access], '@id': 'my_id' }.with_indifferent_access] }
  let(:label) { 'mylabel' }

  it { expect(format_instance.label.call(response, OregonDigital::ControlledVocabularies::Vocabularies::SparMediaType)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(format_instance).to receive(:json).with(anything).and_return(response)
      allow(format_instance).to receive(:find_term).and_return(response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(format_instance.search('https://w3id.org/spar/mediatype/term/id')).to eq [{ id: 'my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(format_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
