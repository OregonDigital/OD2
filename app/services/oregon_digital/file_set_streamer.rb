# frozen_string_literal:true

module OregonDigital
  # Service for streaming a works filesets into a zip file
  class FileSetStreamer
    include Enumerable

    def self.stream(work, &chunks)
      streamer = new(work)
      streamer.each(&chunks)
    end

    attr_reader :work

    def initialize(work)
      @work = work
      @children = work.child_works
    end

    def each(&chunks)
      writer = ZipTricks::BlockWrite.new(&chunks)

      ZipTricks::Streamer.open(writer) do |zip|
        zip.write_deflated_file('metadata.csv') do |file_writer|
          file_writer << work.csv_metadata
          write_children_metadata(file_writer) unless @children.nil?
        end

        stream_works(work, zip)
        @children.each { |child| stream_works(child, zip) }
      end
    end

    private

    def stream_works(work, zip)
      work.file_sets.each do |file_set|
        file = file_set.files.first
        file_name = file.file_name.first

        zip.write_deflated_file(file_name) do |file_writer|
          file.stream.each do |chunk|
            file_writer << chunk
          end
        end
      end
    end

    def write_children_metadata(file_writer)
      @children.each do |child|
        file_writer << "\n"
        file_writer << child.csv_metadata
      end
    end
  end
end
