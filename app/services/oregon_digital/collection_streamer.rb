# frozen_string_literal:true

module OregonDigital
  # Service for streaming a collections sub-collections and works into a zip file
  class CollectionStreamer
    include Enumerable
    include OregonDigital::StreamingDownloadBehavior

    attr_reader :collection

    def initialize(ability, collection, standard)
      # Add in @ability to check the ability to download
      @ability = ability
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

      metadata = [collection.metadata_row(keys, controlled_keys)]
      metadata += stream_child_collections(collection, zip, folder, keys, controlled_keys)
      metadata += stream_child_works(collection, zip, folder, keys, controlled_keys)

      stream_metadata(keys, metadata, folder, zip)
    end

    def stream_child_collections(collection, zip, folder, keys, controlled_keys)
      collection.child_collections.map do |col|
        # Recursively drill down into sub-collections
        stream_collection(col, "#{folder}#{col.id}/", zip)
        col.metadata_row(keys, controlled_keys)
      end
    end

    def stream_child_works(collection, zip, folder, keys, controlled_keys)
      collection.child_works.map do |work|
        # Add low quality works from collection and append metadata
        # Check if the work are able to download from user
        next unless @ability.can?(:download_low, work)

        stream_works_low(work, zip, folder)
        work.metadata_row(keys, controlled_keys)
      end.compact
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
