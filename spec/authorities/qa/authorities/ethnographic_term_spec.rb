# frozen_string_literal:true

RSpec.describe Qa::Authorities::EthnographicTerm do
  let(:ethnograph_term_instance) { described_class.new }
  let(:response) { [{ 'http://www.loc.gov/mads/rdf/v1#authoritativeLabel': [{ '@value': 'mylabel' }], '@id': 'http://id.loc.gov/vocabulary/ethnographicTerms/my_id' }.with_indifferent_access] }

  it { expect(ethnograph_term_instance.label.call(response, OregonDigital::ControlledVocabularies::Vocabularies::LocEthnographicTerms)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(ethnograph_term_instance).to receive(:json).with(anything).and_return(response)
    end

    context 'with a uri in the vocabulary' do
      it { expect(ethnograph_term_instance.search('http://id.loc.gov/vocabulary/ethnographicTerms/my_id')).to eq [{ id: 'http://id.loc.gov/vocabulary/ethnographicTerms/my_id', label: 'mylabel' }.with_indifferent_access] }
    end

    context 'with a uri not in the vocabulary' do
      it { expect(ethnograph_term_instance.search('http://my.queryuri.com')).to eq [] }
    end
  end
end
