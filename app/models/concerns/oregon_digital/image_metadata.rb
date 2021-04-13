# frozen_string_literal:true

module OregonDigital
  # Sets metadata for image work
  module ImageMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit#gid=0

    included do
      initial_properties = properties.keys
      property :photograph_orientation, predicate: RDF::URI.new('http://opaquenamespace.org/ns/photographOrientation'), multiple: false, basic_searchable: false do |index|
        index.as :stored_searchable
      end

      property :view, predicate: RDF::URI.new('http://opaquenamespace.org/ns/cco_viewDescription'), multiple: true, basic_searchable: false do |index|
        index.as :stored_searchable
      end

      property :color_content, predicate: RDF::URI.new('http://rdaregistry.info/Elements/e/P20224'), multiple: true, basic_searchable: false do |index|
        index.as :stored_searchable
      end

      property :resolution, predicate: RDF::Vocab::EXIF.resolution, multiple: false, basic_searchable: false do |index|
        index.as :stored_searchable
      end

      define_singleton_method :image_properties do
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
        form_of_work
        former_owner
        inscription
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
        date_created
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
        rights_note
        rights_statement
        use_restrictions
        repository
        copy_location
        location_copyshelf_location
        local_collection_name
        box_number
        citation
        current_repository_id
        folder_name
        folder_number
        language
        local_collection_id
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
        relation
        resource_type
        workType
        material
        measurements
        physical_extent
        technique
        color_content
        conversion
        exhibit
        institution
        original_filename
        resolution
        full_size_download_allowed
        date_modified
        date_uploaded
      ].freeze
    end
  end
end
