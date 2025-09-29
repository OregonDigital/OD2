# frozen_string_literal: true

describe OregonDigital::AccessibilityFeatureService do
  # SETUP: Create a test variable
  let(:service) { described_class.new }

  # TEST #1: Test to see if the service be able to fetch and return an active term
  describe '#all_labels' do
    it 'returns active terms' do
      expect(service.all_labels('annotations')).to eq ['annotations']
    end
  end
end
