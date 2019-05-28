# frozen_string_literal:true

module OregonDigital
  # Sets metadata for image work
  module ImageMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit#gid=0

    included do
      initial_properties = properties.keys
      property :color_content, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/e/P20224')

      property :color_space, predicate: ::RDF::Vocab::EXIF.colorSpace

      property :height, predicate: ::RDF::Vocab::EXIF.height, multiple: false

      property :orientation, predicate: ::RDF::Vocab::EXIF.orientation

      property :photograph_orientation, advance_search: false, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/photographOrientation'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :resolution, predicate: ::RDF::Vocab::EXIF.resolution, multiple: false

      property :view, advance_search: true, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/cco_viewDescription') do |index|
        index.as :stored_searchable
      end

      property :width, predicate: ::RDF::Vocab::EXIF.width, multiple: false

      define_singleton_method :image_properties do
        (properties.reject { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys - (Generic.generic_properties + initial_properties))
      end
    end
  end
end
