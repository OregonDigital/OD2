# frozen_string_literal: true

describe OregonDigital::LocalContextService do
  # SETUP: Create a test variable
  let(:service) { described_class.new }

  # TEST: Test to see if the service be able to fetch and return an active term
  describe '#all_labels' do
    it 'returns active terms' do
      expect(service.all_labels('http://localcontexts.org/label/tk-attribution/')).to eq ['TK Attribution (TK A)']
    end
  end
end
