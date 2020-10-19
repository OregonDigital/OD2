module OregonDigital
  class CollectionStreamer
    include Enumerable

    def self.stream(collection, &chunks)
      streamer = new(collection)
      streamer.each(&chunks)
    end

    attr_reader :collection

    def initialize(collection)
      @collection = collection
    end

    def each(&chunks)
      writer = ZipTricks::BlockWrite.new(&chunks)

      ZipTricks::Streamer.open(writer) do |zip|
        stream_collection(collection, '/', zip)
      end
    end

    def stream_collection(collection, folder, zip_streamer)
      # Recursively drill down into sub-collections
      collection.child_collections.each do |collection|
        stream_collection(collection, "#{folder}#{collection.id}/", zip_streamer)
      end

      # Add collection metadata
      zip_streamer.write_deflated_file("#{folder}metadata.csv") do |file_writer|
        file_writer << collection.csv_metadata
      end

      # Add files from works in this collection
      collection.child_works.each do |work|
        work.file_sets.each do |file_set|
          file_name = "#{folder}#{file_set.title.first}"

          zip_streamer.write_deflated_file(file_name) do |file_writer|
            file_set.files.first.stream.each do |chunk|
              file_writer << chunk
            end
          end
        end
      end
    end
  end
end
