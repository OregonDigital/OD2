# frozen_string_literal:true

module OregonDigital
  # Sets metadata for video work
  module VideoMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing

    included do
      initial_properties = properties.keys
      property :height, advance_search: true, predicate: ::RDF::Vocab::EXIF.height, multiple: false do |index|
        index.as :stored_searchable
      end
      property :width, advance_search: true, predicate: ::RDF::Vocab::EXIF.width, multiple: false do |index|
        index.as :stored_searchable
      end
      define_singleton_method :video_properties do
        (properties.reject { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys - (Generic.generic_properties + initial_properties))
      end
    end
  end
end
