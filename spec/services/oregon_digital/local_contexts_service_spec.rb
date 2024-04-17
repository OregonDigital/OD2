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
      expect(service.parse_labels_for_image(['TK Attribution (TK A)', 'Attribution Incomplete', 'BC Multiple Communities (BC MC)'])).to eq ['tk_a', 'attribution_incomplete', 'bc_mc']
    end
  end

  # TEST #3: Test to see if the service be able to get the correct size for indicator
  describe '#get_carousel_indicator_size' do
    it 'returns 1 indicator for any number less or equal to 4' do
      expect(service.get_carousel_indicator_size(3)).to eq 1
      expect(service.get_carousel_indicator_size(4)).to eq 1
      expect(service.get_carousel_indicator_size(2)).to eq 1
    end

    it 'returns many indicators for any number greater than 4 when divisible by 4' do
      expect(service.get_carousel_indicator_size(20)).to eq 5
      expect(service.get_carousel_indicator_size(12)).to eq 3
      expect(service.get_carousel_indicator_size(32)).to eq 8
    end

    it 'returns many indicators for any number greater than 4 when it not divisible by 4' do
      expect(service.get_carousel_indicator_size(23)).to eq 6
      expect(service.get_carousel_indicator_size(13)).to eq 4
      expect(service.get_carousel_indicator_size(38)).to eq 10
    end
  end
end
