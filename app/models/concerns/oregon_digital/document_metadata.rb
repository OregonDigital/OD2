# frozen_string_literal:true

module OregonDigital
  # Sets metadata for a document
  module DocumentMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing
    included do
      initial_properties = properties.keys
      property :contained_in_journal, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasJournal') do |index|
        index.as :stored_searchable
      end

      property :first_line, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLine'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :first_line_chorus, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_firstLineChorus'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :has_number, basic_searchable: false, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasNumber') do |index|
        index.as :stored_searchable, :facetable
      end

      property :instrumentation, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_instrumentation') do |index|
        index.as :stored_searchable
      end

      property :is_volume, basic_searchable: false, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasVolume') do |index|
        index.as :stored_searchable, :facetable
      end

      property :larger_work, basic_searchable: false, predicate: ::RDF::URI('http://opaquenamespace.org/ns/sheetmusic_largerWork') do |index|
        index.as :stored_searchable
      end

      property :on_pages, basic_searchable: false, predicate: ::RDF::URI('http://purl.org/net/nknouf/ns/bibtex/hasPages') do |index|
        index.as :stored_searchable
      end

      property :table_of_contents, predicate: ::RDF::Vocab::DC.tableOfContents do |index|
        index.as :stored_searchable
      end

      define_singleton_method :document_properties do
        (properties.reject { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys - (Generic.generic_properties + initial_properties))
      end

      ORDERED_TERMS = %i[
        alternative
        tribal_title
        title
        creator
        photographer
        arranger
        artist
        author
        cartographer
        collector
        composer
        creator_display
        contributor
        dedicatee
        designer
        donor
        editor
        illustrator
        interviewee
        interviewer
        lyricist
        owner
        patron
        print_maker
        recipient
        transcriber
        translator
        description
        abstract
        biographical_information
        compass_direction
        cover_description
        coverage
        description_of_manifestation
        designer_inscription
        first_line
        first_line_chorus
        form_of_work
        former_owner
        inscription
        instrumentation
        layout
        military_highest_rank
        military_occupation
        military_service_location
        mode_of_issuance
        mods_note
        motif
        object_orientation
        photograph_orientation
        tribal_notes
        source_condition
        table_of_contents
        temporal
        view
        subject
        award
        cultural_context
        ethnographic_term
        event
        keyword
        legal_name
        military_branch
        sports_team
        state_or_edition
        style_or_period
        tribal_classes
        tribal_terms
        phylum_or_division
        taxon_class
        order
        family
        genus
        species
        common_name
        accepted_name_usage
        original_name_usage
        scientific_name_authorship
        specimen_type
        identification_verification_status
        location
        box
        gps_latitude
        gps_longitude
        ranger_district
        street_address
        tgn
        water_basin
        date
        acquisition_date
        award_date
        collected_date
        ate_created
        issued
        view_date
        accession_number
        barcode
        hydrologic_unit_code
        identifier
        item_locator
        longitude_latitude_identification
        license
        access_restrictions
        copyright_claimant
        rights_holder
        rights_statement
        use_restrictions
        repository
        copy_location
        location_copyshelf_location
        local_collection_name
        box_number
        citation
        contained_in_journal
        current_repository_id
        folder_name
        folder_number
        has_number
        is_volume
        language
        local_collection_id
        on_pages
        publisher
        place_of_production
        provenance
        publication_place
        series_name
        series_number
        source
        art_series
        has_finding_aid
        has_part
        has_version
        isPartOf
        is_version_of
        larger_work
        relation
        resource_type
        workType
        material
        measurements
        physical_extent
        technique
      ].freeze
    end
  end
end
