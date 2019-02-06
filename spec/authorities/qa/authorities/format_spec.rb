# frozen_string_literal:true

RSpec.describe Qa::Authorities::Format do
  let(:format_instance) { described_class.new }
  let(:response) { [{ 'http://www.w3.org/2000/01/rdf-schema#label': [{ '@value': 'mylabel' }], '@id': 'my_id' }.with_indifferent_access] }

  it { expect(format_instance.label.call(response)).to eq 'mylabel' }
  describe '#search' do
    before do
      allow(format_instance).to receive(:json).with(anything).and_return(response)
      allow(format_instance).to receive(:build_query_url).with('http://my.queryuri.com').and_return(response)
    end
    it { expect(format_instance.search('http://my.queryuri.com')).to eq [{ id: 'my_id', label: 'mylabel' }.with_indifferent_access] }
  end
end
