# frozen_string_literal:true

module OregonDigital
  module DocumentMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing
    PROPERTIES = %w[contained_in_journal first_line first_line_chorus has_number host_item instrumentation is_volume larger_work number_of_pages table_of_contents].freeze

    included do
      property :contained_in_journal, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasJournal') do |index|
        index.as :stored_searchable
      end

      property :first_line, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLine'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :first_line_chorus, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLineChorus'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :has_number, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasNumber') do |index|
        index.as :stored_searchable, :facetable
      end

      property :host_item, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_hostItem') do |index|
        index.as :stored_searchable
      end

      property :instrumentation, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_instrumentation') do |index|
        index.as :stored_searchable
      end

      property :is_volume, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasVolume') do |index|
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
    end
  end
end
