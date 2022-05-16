# frozen_string_literal: true

module OregonDigital
  # Shared fileset/collection streaming methods
  module StreamingDownloadBehavior
    extend ActiveSupport::Concern

    included do
      def self.stream(concern, standard = true, &chunks)
        streamer = new(concern, standard)
        streamer.each(&chunks)
      end
    end

    private

    # Stream original quality files
    def stream_works(work, zip)
      work.file_sets.each do |file_set|
        stream_files_from_fileset(file_set, zip)
      end
    end

    # Stream low quality files
    def stream_works_low(work, zip, folder = '')
      work.file_sets.each do |file_set|
        file_name = "#{folder}#{file_set.label}"
        deriv_name = derivative_name(file_set)
        # If this fileset doesn't have derivatives, stream in the original quality
        return stream_files_from_fileset(file_set, zip, folder) if deriv_name.blank?

        # Stream the file from derivative on disk
        zip.write_deflated_file(file_name) do |file_writer|
          File.open(Hyrax::DerivativePath.derivative_path_for_reference(file_set, deriv_name), 'rb') do |source|
            IO.copy_stream(source, file_writer)
          end
        end
      end
    end

    # Stream original quality files directly from Fedora
    def stream_files_from_fileset(file_set, zip, folder = '')
      files = file_set.files
      # Some filesets have multiple files
      files.each do |file|
        file_name = "#{folder}#{file.file_name.first}"
        # And some of those files are empty/broken
        next if file_name.blank?

        zip.write_deflated_file(file_name) do |file_writer|
          file.stream.each do |chunk|
            file_writer << chunk
          end
        end
      end
    end

    # Determine the low quality derivative
    def derivative_name(file_set)
      deriv_name = if file_set.image? || file_set.pdf?
                     'jpeg'
                   elsif file_set.audio?
                     'mp3'
                   elsif file_set.video?
                     'mp4'
                   elsif file_set.office_document?
                     'thumbnail'
                   end
      # nil = other files get full size
      return deriv_name
    end
  end
end
