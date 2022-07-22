# frozen_string_literal:true

module OregonDigital
  # Service for streaming a works filesets into a zip file
  class FileSetStreamer
    include Enumerable
    include OregonDigital::StreamingDownloadBehavior

    attr_reader :work

    def self.stream_metadata(curation_concern)
      # Build a CSV of label headers and metadata value data
      ::CSV.generate do |csv|
        csv << metadata_keys
        csv << curation_concern.metadata_row(metadata_keys, controlled_keys)
        curation_concern.child_works.each do |work|
          csv << work.metadata_row(metadata_keys, controlled_keys)
        end
      end
    end

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
          file_writer << work.csv_metadata(self.class.metadata_keys, self.class.controlled_keys)
        end

        # Stream work files and child work files, determining if low original quality
        @standard ? stream_works_low(work, zip) : stream_works(work, zip)
        @children.each { |child| @standard ? stream_works_low(child, zip) : stream_works(child, zip) }
      end
    end
  end
end
