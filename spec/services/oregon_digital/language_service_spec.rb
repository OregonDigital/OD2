# frozen_string_literal: true

describe OregonDigital::LanguageService do
  let(:service) { described_class.new }

  describe '#all_labels' do
    it 'returns active terms' do
      expect(service.all_labels('http://id.loc.gov/vocabulary/iso639-2/eng')).to eq ['English']
    end
  end
end
