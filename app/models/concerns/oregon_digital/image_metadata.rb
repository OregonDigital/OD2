# frozen_string_literal:true

module OregonDigital
  # Sets metadata for image work
  module ImageMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit#gid=0

    included do
      initial_properties = self.properties.keys
      property :color_content, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/e/P20224') do |index|
        index.as :stored_searchable
      end

      property :color_space, predicate: ::RDF::Vocab::EXIF.colorSpace do |index|
        index.as :stored_searchable
      end

      property :height, predicate: ::RDF::Vocab::EXIF.height, multiple: false

      property :orientation, predicate: ::RDF::Vocab::EXIF.orientation do |index|
        index.as :stored_searchable
      end

      property :photograph_orientation, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/photographOrientation'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :resolution, predicate: ::RDF::Vocab::EXIF.resolution, multiple: false do |index|
        index.as :stored_searchable
      end

      property :view, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/cco_viewDescription') do |index|
        index.as :stored_searchable
      end

      property :width, predicate: ::RDF::Vocab::EXIF.width, multiple: false

      define_singleton_method :image_properties do
        (self.properties.select { |k, v| v.class_name.nil? }.keys - initial_properties).map(&:to_sym)
      end
    end
  end
end
