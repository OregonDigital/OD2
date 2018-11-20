module OD2
  module DocumentMetadata
    extend ActiveSupport::Concern
     # Usage notes and expectations can be found in the Metadata Application Profile:
     # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing
     included do

       property :contained_in_journal, :predicate => ::RDF::URI('http://sw-portal.deri.org/ontologies/swportal/containedInJournal') do |index|
         index.as :stored_searchable
       end

       property :first_line, :predicate => ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLine'), multiple: false do |index|
         index.as :stored_searchable
       end

       property :first_line_chorus, :predicate => ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLineChorus'), multiple: false do |index|
         index.as :stored_searchable
       end

       property :has_number, :predicate => ::RDF::URI('http://sw-portal.deri.org/ontologies/swportal/hasNumber') do |index|
         index.as :stored_searchable
       end

       property :host_item, :predicate => ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_hostItem') do |index|
         index.as :stored_searchable
       end

       property :instrumentation, :predicate => ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_instrumentation') do |index|
         index.as :stored_searchable
       end

       property :is_volume, :predicate => ::RDF::URI('http://sw-portal.deri.org/ontologies/swportal/isVolume') do |index|
         index.as :stored_searchable
       end

       property :larger_work, :predicate => ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_largerWork') do |index|
         index.as :stored_searchable
       end

       property :number_of_pages, :predicate => ::RDF::Vocab::SCHEMA.numberOfPages do |index|
         index.as :stored_searchable
       end

       property :table_of_contents, :predicate => ::RDF::Vocab::DC.tableOfContents do |index|
         index.as :stored_searchable
       end

     end
   end
end
