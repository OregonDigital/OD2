# frozen_string_literal:true

module OregonDigital
  # Behavior to download data about a work
  module DownloadControllerBehavior
    def download
      send_data curation_concern.zip_files.string, filename: "#{curation_concern.id}.zip"
    end
  end
end
