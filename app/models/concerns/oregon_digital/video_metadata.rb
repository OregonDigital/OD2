# frozen_string_literal:true

module OregonDigital
  # Sets metadata for video work
  module VideoMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing

    included do
      initial_properties = self.properties.keys
      property :height, predicate: ::RDF::Vocab::EXIF.height, multiple: false
      property :width, predicate: ::RDF::Vocab::EXIF.width, multiple: false
      define_singleton_method :video_properties do
        (self.properties.select { |k, v| v.class_name.nil? }.keys - initial_properties).map(&:to_sym)
      end
    end
  end
end
