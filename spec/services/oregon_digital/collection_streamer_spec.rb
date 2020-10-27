# frozen_string_literal: true

describe OregonDigital::CollectionStreamer do
  let(:service_class) { described_class }
  let(:collection) { build(:collection) }

  describe '#stream' do
    it 'assembles a zip out of chunks' do
      chunk_count = 0
      service_class.stream(collection) do
        chunk_count += 1
      end
      expect(chunk_count).to eq 46
    end
  end
end
