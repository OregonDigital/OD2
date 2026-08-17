# frozen_string_literal: true

module OregonDigital
  # A service to extract the metadata of alt text in image file
  class FileSetAltTextsExtractorService
    # PATH: Setup path for tool usage of EXIFTOOL
    EXIFTOOL = '/opt/fits/tools/exiftool/perl/exiftool'

    # METHOD: Extract the text out of file
    def self.extract(file_path)
      # EXECUTE: Call the command to fetch the alt text out of the file while ignore header & warning message
      texts_extracted = `perl #{EXIFTOOL} -AltTextAccessibility -ImageDescription -s3 "#{file_path}" 2>/dev/null`
      texts_extracted.split("\n").map(&:strip).reject(&:empty?).first
    end
  end
end
