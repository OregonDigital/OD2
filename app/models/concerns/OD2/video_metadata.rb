module OD2
  module VideoMetadata
    extend ActiveSupport::Concern

    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing

    included do

      property :height, predicate: ::RDF::Vocab::EXIF.height, multiple: false do |index|
        index.as :stored_searchable
      end

      property :width, predicate: ::RDF::Vocab::EXIF.width, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
