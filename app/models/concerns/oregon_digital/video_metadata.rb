# frozen_string_literal:true

module OregonDigital
  # Sets metadata for video work
  module VideoMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing

    PROPERTIES = %w[height width].freeze

    included do
      property :height, predicate: ::RDF::Vocab::EXIF.height, multiple: false

      property :width, predicate: ::RDF::Vocab::EXIF.width, multiple: false
    end
  end
end
