# frozen_string_literal: true

describe OregonDigital::FileSetStreamer do
  let(:service_class) { described_class }
  let(:work) { build(:work) }

  describe '#stream' do
    before do
      allow(work).to receive(:metadata_row).and_return([])
    end

    it 'assembles a zip out of chunks' do
      chunk_count = 0
      service_class.stream(work) do
        chunk_count += 1
      end
      expect(chunk_count).to eq 9
    end
  end
end
