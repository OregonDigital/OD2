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

      # CHECK: To see if collection is user collection
      if @collection.collection_type.machine_id.to_s == 'user_collection' || @collection.collection_type.machine_id.to_s == 'digital_collection'
        ZipTricks::Streamer.open(writer, auto_rename_duplicate_filenames: true) do |zip|
          stream_user_collection(collection, '', zip)
        end
      else
        ZipTricks::Streamer.open(writer, auto_rename_duplicate_filenames: true) do |zip|
          stream_collection(collection, '', zip)
        end
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

    # METHOD: Create a special stream method for user collection
    def stream_user_collection(collection, folder, zip)
      # COLLECTION: Recursively drill down into sub-collections
      collection.child_collections.map do |col|
        # Recursively drill down into sub-collections
        stream_collection(col, "#{folder}#{col.id}/", zip)
      end

      # WORK: Append child works from collection in zip folder
      collection.child_works.map do |work|
        # Add low quality works from collection and append metadata
        stream_works_low(work, zip, folder) if work.visibility == 'open'
      end
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
        stream_works_low(work, zip, folder)
        work.metadata_row(keys, controlled_keys)
      end
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
