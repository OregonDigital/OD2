# frozen_string_literal:true

module OregonDigital
  # Behavior to download data about a work
  module DownloadControllerBehavior
    extend ActiveSupport::Concern
    include ActionController::Live

    def download_low
      download
    end

    def download
      zipname = "#{curation_concern.id}.zip"

      send_file_headers!(
        type: "application/zip",
        disposition: "attachment",
        filename: zipname
      )
      response.headers["Last-Modified"] = Time.now.httpdate.to_s
      response.headers["X-Accel-Buffering"] = "no"

      OregonDigital::FileSetStreamer.stream(curation_concern.file_sets) do |chunk|
        response.stream.write(chunk)
      end
    ensure
      response.stream.close
    end

    def metadata
      send_data curation_concern.csv_metadata, filename: "#{curation_concern.id}.csv"
    end
  end
end
