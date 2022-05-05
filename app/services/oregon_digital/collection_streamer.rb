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

    # def stream_works_low(work, folder = '', zip)
    #   work.file_sets.each do |file_set|
    #     file_name = "#{folder}#{file_set.label}"
    #     deriv_name = derivative_name(file_set)


    #     begin
    #       file = File.open(Hyrax::DerivativePath.derivative_path_for_reference(file_set, deriv_name), 'rb')
    #       zip.write_deflated_file(file_name) do |file_writer|
    #         IO.copy_stream(file, file_writer)
    #       end
    #       file.close
    #     rescue Errno::ENOENT
    #       stream_files_from_fileset(file_set, zip)
    #     end
    #   end
    # end
  end
end
