# frozen_string_literal: true

describe OregonDigital::CollectionStreamer do
  let(:service_class) { described_class }
  let(:collection) { build(:collection) }
  let(:streamer) { service_class.new('ability', collection, false) }

  describe '#stream' do
    it 'assembles a zip out of chunks' do
      chunk_count = 0
      service_class.stream_col('ability', collection) do
        chunk_count += 1
      end
      expect(chunk_count).to eq 46
    end
  end

  describe '#stream_collection' do
    before do
      allow(streamer).to receive(:stream_child_collections).and_return([])
      allow(streamer).to receive(:stream_child_works).and_return([])
      allow(collection).to receive(:metadata_row).and_return([])
      allow(nil).to receive(:write_deflated_file).and_return(nil)
    end

    it 'calls metadata_row on the collection' do
      expect(collection).to receive(:metadata_row)
      streamer.send(:stream_collection, collection, '/', nil)
    end

    it 'calls stream_child_collections' do
      expect(streamer).to receive(:stream_child_collections)
      streamer.send(:stream_collection, collection, '/', nil)
    end

    it 'calls stream_child_works' do
      expect(streamer).to receive(:stream_child_works)
      streamer.send(:stream_collection, collection, '/', nil)
    end
  end
end
