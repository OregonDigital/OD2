# frozen_string_literal: true

describe OregonDigital::LocalContextsService do
  # SETUP: Create a test variable
  let(:service) { described_class.new }

  # TEST #1: Test to see if the service be able to fetch and return an active term
  describe '#all_labels' do
    it 'returns active terms' do
      expect(service.all_labels('http://localcontexts.org/label/tk-attribution/')).to eq ['TK Attribution (TK A)']
    end
  end

  # TEST #2: Test to see if the service be able to parse out the labels
  describe '#parse_labels_for_image' do
    it 'returns parsable array path for image for display' do
      expect(service.parse_labels_for_image(['TK Attribution (TK A)', 'Attribution Incomplete', 'BC Multiple Communities (BC MC)'])).to eq %w[tk_a attribution_incomplete bc_mc]
    end
  end
end
