# frozen_string_literal:true

module OregonDigital
  # Service for streaming a works filesets into a zip file
  class FileSetStreamer
    include Enumerable
    include OregonDigital::StreamingDownloadBehavior

    attr_reader :work

    def initialize(work, standard)
      @work = work
      @standard = standard
      @children = work.child_works
    end

    def each(&chunks)
      writer = ZipTricks::BlockWrite.new(&chunks)

      ZipTricks::Streamer.open(writer, auto_rename_duplicate_filenames: true) do |zip|
        # Add metadata
        zip.write_deflated_file('metadata.csv') do |file_writer|
          file_writer << work.csv_metadata
          write_children_metadata(file_writer) unless @children.nil?
        end

        # Stream work files and child work files, determining if low original quality
        @standard ? stream_works_low(work, zip) : stream_works(work, zip)
        @children.each { |child| @standard ? stream_works_low(child, zip) : stream_works(child, zip) }
      end
    end

    private

    def write_children_metadata(file_writer)
      @children.each do |child|
        file_writer << "\n"
        file_writer << child.csv_metadata
      end
    end
  end
end
