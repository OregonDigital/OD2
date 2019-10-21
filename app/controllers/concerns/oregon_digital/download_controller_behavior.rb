# frozen_string_literal:true

module OregonDigital
  # Behavior to download data about a work
  module DownloadControllerBehavior
    def download_low
      send_data curation_concern.zip_files.string, filename: "#{curation_concern.id}.zip"
    end

    def download
      send_data curation_concern.zip_files.string, filename: "#{curation_concern.id}.zip"
    end

    def metadata
      send_data curation_concern.csv_metadata, filename: "#{curation_concern.id}.csv"
    end
  end
end
