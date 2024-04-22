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

  # TEST #3: Test to see if the service be able to get the correct size for indicator
  describe '#get_row_size' do
    it 'returns 1 rows for any number less or equal to 4' do
      expect(service.get_row_size(3)).to eq 1
      expect(service.get_row_size(4)).to eq 1
      expect(service.get_row_size(2)).to eq 1
    end

    it 'returns many rows for any number greater than 4 when divisible by 4' do
      expect(service.get_row_size(20)).to eq 5
      expect(service.get_row_size(12)).to eq 3
      expect(service.get_row_size(32)).to eq 8
    end

    it 'returns many rows for any number greater than 4 when it not divisible by 4' do
      expect(service.get_row_size(23)).to eq 6
      expect(service.get_row_size(13)).to eq 4
      expect(service.get_row_size(38)).to eq 10
    end
  end

  # TEST #4: Test to see if the service be able to split array out to chunk
  describe '#split_array_chunk' do
    let(:test_arr1) { [1, 2, 3, 4] }
    let(:test_arr2) { [1, 2, 3, 4, 5] }
    let(:test_arr3) { [1, 2, 3, 4, 5, 6] }

    it 'returns the split chunk array correctly' do
      expect(service.split_array_chunk(test_arr1)).to eq [[1, 2, 3, 4]]
      expect(service.split_array_chunk(test_arr2)).to eq [[1, 2, 3, 4], [5]]
      expect(service.split_array_chunk(test_arr3)).to eq [[1, 2, 3, 4], [5, 6]]
    end
  end
end
