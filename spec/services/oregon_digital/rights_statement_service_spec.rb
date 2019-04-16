# frozen_string_literal: true

describe OregonDigital::RightsStatementService do
  let(:service) { described_class.new }

  describe '#all_labels' do
    it 'returns active terms' do
      expect(service.all_labels('http://rightsstatements.org/vocab/InC/1.0/')).to eq ['In Copyright']
    end
  end
end
