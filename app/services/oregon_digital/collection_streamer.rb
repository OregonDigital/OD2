# frozen_string_literal:true

module OregonDigital
  # Service for streaming a collections sub-collections and works into a zip file
  class CollectionStreamer
    include Enumerable
    include OregonDigital::StreamingDownloadBehavior

    attr_reader :collection

    def initialize(collection, standard)
      @collection = collection
      @standard = standard
    end

    def each(&chunks)
      writer = ZipTricks::BlockWrite.new(&chunks)

      ZipTricks::Streamer.open(writer, auto_rename_duplicate_filenames: true) do |zip|
        stream_collection(collection, '', zip)
      end
    end

    private

    def stream_collection(collection, folder, zip)
      keys = self.class.metadata_keys
      controlled_keys = self.class.controlled_keys

      metadata = []
      metadata << collection.metadata_row(keys, controlled_keys)
      collection.child_collections.each do |col|
        # Recursively drill down into sub-collections
        stream_collection(col, "#{folder}#{col.id}/", zip)
        metadata << col.metadata_row(keys, controlled_keys)
      end
      collection.child_works.each do |work|
        # Add low quality works from collection and append metadata
        stream_works_low(work, zip, folder)
        metadata << work.metadata_row(keys, controlled_keys)
      end

      stream_metadata(keys, metadata, folder, zip)
    end

    # Add all metadata
    def stream_metadata(keys, metadata, folder, zip)
      csv_file = ::CSV.generate do |csv|
        csv << keys
        metadata.each do |row|
          csv << row
        end
      end

      zip.write_deflated_file("#{folder}metadata.csv") do |file_writer|
        file_writer << csv_file
      end
    end
  end
end
