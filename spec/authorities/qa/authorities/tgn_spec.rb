# frozen_string_literal:true

RSpec.describe Qa::Authorities::Tgn do
  let(:tgn_instance) { described_class.new }
  let(:response) { [{ 'identified_by': [{ 'classified_as': [{ 'id': 'http://vocab.getty.edu/term/type/Descriptor' }], 'content': 'mylabel' }], 'id': 'http://vocab.getty.edu/tgn/term_id' }.with_indifferent_access] }

  it { expect(tgn_instance.label.call(response, OregonDigital::ControlledVocabularies::Vocabularies::GettyTgn)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(tgn_instance).to receive(:json).with(anything).and_return(response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(tgn_instance.search('http://vocab.getty.edu/tgn/term_id')).to eq [{ id: 'http://vocab.getty.edu/tgn/term_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(tgn_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
