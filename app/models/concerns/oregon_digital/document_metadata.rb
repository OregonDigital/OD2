# frozen_string_literal:true

module OregonDigital
  # Sets metadata for a document
  module DocumentMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing
    included do
      initial_properties = properties.keys

      # property :box_number, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/boxNumber') do |index|
      #   index.as :stored_searchable, :facetable
      # end

      property :contained_in_journal, advance_search: false, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasJournal') do |index|
        index.as :stored_searchable
      end

      property :first_line, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLine'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :first_line_chorus, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLineChorus'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :has_number, advance_search: true, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasNumber') do |index|
        index.as :stored_searchable, :facetable
      end

      property :instrumentation, advance_search: false, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_instrumentation') do |index|
        index.as :stored_searchable
      end

      property :is_volume, advance_search: true, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasVolume') do |index|
        index.as :stored_searchable, :facetable
      end

      property :larger_work, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_largerWork') do |index|
        index.as :stored_searchable
      end

      property :number_of_pages, predicate: ::RDF::Vocab::SCHEMA.numberOfPages do |index|
        index.as :stored_searchable
      end

      property :table_of_contents, predicate: ::RDF::Vocab::DC.tableOfContents do |index|
        index.as :stored_searchable
      end

      define_singleton_method :document_properties do
        (properties.reject { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys - (Generic.generic_properties + initial_properties))
      end
    end
  end
end
