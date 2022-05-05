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
        stream_collection(collection, '/', zip)
      end
    end

    private

    def stream_collection(collection, folder, zip)
      # Recursively drill down into sub-collections
      collection.child_collections.each do |col|
        stream_collection(col, "#{folder}#{col.id}/", zip)
      end

      # Add collection metadata
      zip.write_deflated_file("#{folder}metadata.csv") do |file_writer|
        file_writer << collection.csv_metadata
      end

      # Add low quality works from collection
      collection.child_works.each do |work|
        stream_works_low(work, zip, folder)
      end
    end
  end
end
