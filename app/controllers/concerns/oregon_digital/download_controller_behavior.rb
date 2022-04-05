# frozen_string_literal:true

module OregonDigital
  # Behavior to download data about a work
  module DownloadControllerBehavior
    extend ActiveSupport::Concern
    include ActionController::Live

    def download_low
      download(true)
    end

    # Use OregonDigital::FileSetSreamer service to find all file sets and split the response into a stream of chunks
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def download(standard_size = false)
      zipname = "#{curation_concern.id}.zip"

      send_file_headers!(
        type: 'application/zip',
        disposition: 'attachment',
        filename: zipname
      )
      response.headers['Last-Modified'] = Time.now.httpdate.to_s
      response.headers['X-Accel-Buffering'] = 'no'

      OregonDigital::FileSetStreamer.stream(curation_concern, standard_size) do |chunk|
        response.stream.write(chunk)
      end
    ensure
      response.stream.close
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def metadata
      send_data curation_concern.csv_metadata, filename: "#{curation_concern.id}.csv"
    end
  end
end
