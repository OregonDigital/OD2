# frozen_string_literal:true

RSpec.describe Qa::Authorities::Format do
  let(:format_instance) { described_class.new }
  let(:response) { [{'http://www.w3.org/2000/01/rdf-schema#label': [{'@value': 'mylabel'], '@id': 'my_id'}] } }

  it { format_instance.label.call(label_hash) eq 'my_label'}
  describe "#search" do
    before do
      allow(format_instance).to receive(:json).with(:anything).and_return(response)
      allow(format_instance).to receive(:build_query_url).with('http://my.queryuri.com').and_return(response)
    end
    it { format_instance.search('http://my.queryuri.com') eq [{'id': 'my_id', 'label': 'mylabel' }] }
  end
end
