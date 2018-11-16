module OD2
  module GenericMetadata
    extend ActiveSupport::Concern

    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit?usp=sharing

    included do
      # Set the visibility for all works
      after_initialize :set_default_visibility
      def set_default_visibility
        self.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC if new_record?
      end

      # Provide each model a hook to set property defaults
      after_initialize :set_defaults, unless: :persisted?

      property :alternative, predicate: ::RDF::Vocab::DC.alternative do |index|
        index.as :stored_searchable
      end

      property :caption_title, predicate: ::RDF::Vocab::ONS.captionTitle do |index|
        index.as :stored_searchable
      end

      property :tribal_title, predicate: ::RDF::Vocab::ONS.tribalTitle do |index|
        index.as :stored_searchable
      end

      property :arranger, predicate: ::RDF::Vocab::marcrel.arr do |index|
        index.as :stored_searchable, :facetable
      end

      property :artist, predicate: ::RDF::Vocab::marcrel.art do |index|
        index.as :stored_searchable, :facetable
      end

      property :author, predicate: ::RDF::Vocab::marcrel.aut do |index|
        index.as :stored_searchable, :facetable
      end

      property :cartographer, predicate: ::RDF::Vocab::marcrel.ctg do |index|
        index.as :stored_searchable, :facetable
      end

      property :collector, predicate: ::RDF::Vocab::marcrel.col do |index|
        index.as :stored_searchable, :facetable
      end

      property :composer, predicate: ::RDF::Vocab::marcrel.cmp do |index|
        index.as :stored_searchable, :facetable
      end

      property :creator_display, predicate: ::RDF::Vocab::ONS.cco_creatorDisplay do |index|
        index.as :stored_searchable, :facetable
      end

      property :dedicatee, predicate: ::RDF::Vocab::marcrel.dte do |index|
        index.as :stored_searchable, :facetable
      end

      property :donor, predicate: ::RDF::Vocab::marcrel.dnr do |index|
        index.as :stored_searchable, :facetable
      end

      property :designer, predicate: ::RDF::Vocab::marcrel.dsr do |index|
        index.as :stored_searchable, :facetable
      end

      property :editor, predicate: ::RDF::Vocab::marcrel.edt do |index|
        index.as :stored_searchable, :facetable
      end

      property :former_owner, predicate: ::RDF::Vocab::marcrel.fmo do |index|
        index.as :stored_searchable, :facetable
      end

      property :illustrator, predicate: ::RDF::Vocab::marcrel.ill do |index|
        index.as :stored_searchable, :facetable
      end

      property :interviewee, predicate: ::RDF::Vocab::marcrel.ive do |index|
        index.as :stored_searchable, :facetable
      end

      property :interviewer, predicate: ::RDF::Vocab::marcrel.ivr do |index|
        index.as :stored_searchable, :facetable
      end

      property :lyricist, predicate: ::RDF::Vocab::marcrel.lyr do |index|
        index.as :stored_searchable, :facetable
      end

      property :owner, predicate: ::RDF::Vocab::marcrel.own do |index|
        index.as :stored_searchable, :facetable
      end

      property :patron, predicate: ::RDF::Vocab::marcrel.pat do |index|
        index.as :stored_searchable, :facetable
      end

      property :photographer, predicate: ::RDF::Vocab::marcrel.pht do |index|
        index.as :stored_searchable, :facetable
      end

      property :print_maker, predicate: ::RDF::Vocab::marcrel.prm do |index|
        index.as :stored_searchable, :facetable
      end

      property :recipient, predicate: ::RDF::Vocab::marcrel.rcp do |index|
        index.as :stored_searchable, :facetable
      end

      property :scribe, predicate: ::RDF::Vocab::marcrel.scr do |index|
        index.as :stored_searchable, :facetable
      end

      property :transcriber, predicate: ::RDF::Vocab::marcrel.trc do |index|
        index.as :stored_searchable, :facetable
      end

      property :translator, predicate: ::RDF::Vocab::marcrel.trl do |index|
        index.as :stored_searchable, :facetable
      end

      property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
        index.as :stored_searchable
      end

      property :accepted_name_usage, predicate: ::RDF::Vocab::dwcterms.acceptedNameUsage do |index|
        index.as :stored_searchable
      end

      property :biographical_information, predicate: ::RDF::Vocab::rdaa.biographicalinformation do |index|
        index.as :stored_searchable
      end

      property :canzoniere_poems, predicate: ::RDF::Vocab::ons.canzonierePoems do |index|
        index.as :stored_searchable
      end

      property :compass_direction, predicate: ::RDF::Vocab::ons.compassDirection do |index|
        index.as :stored_searchable
      end

      property :contents, predicate: ::RDF::Vocab::ons.contents do |index|
        index.as :stored_searchable
      end

      property :cover_description, predicate: ::RDF::Vocab::ons.coverDescription do |index|
        index.as :stored_searchable
      end

      property :cover, predicate: ::RDF::Vocab::dce.cover do |index|
        index.as :stored_searchable
      end

      property :description_of_manifestation, predicate: ::RDF::Vocab::rdam.descriptionofmanifestation do |index|
        index.as :stored_searchable
      end

      property :form_of_work, predicate: ::RDF::Vocab::rdaw.formofwork do |index|
        index.as :stored_searchable
      end

      property :identification_verification_status, predicate: ::RDF::Vocab::dwcterms.identificationVerificationStatus do |index|
        index.as :stored_searchable
      end

      property :inscription, predicate: ::RDF::Vocab::ons.vra_inscription do |index|
        index.as :stored_searchable
      end

      property :layout, predicate: ::RDF::Vocab::rdam.P30155 do |index|
        index.as :stored_searchable
      end

      property :military_highest_rank, predicate: ::RDF::Vocab::ons.militaryHighestRank do |index|
        index.as :stored_searchable
      end

      property :military_occupation, predicate: ::RDF::Vocab::ons.militaryOccupation do |index|
        index.as :stored_searchable
      end

      property :military_service_location, predicate: ::RDF::Vocab::ons.militaryServiceLocation do |index|
        index.as :stored_searchable
      end

      property :mode_of_issuance, predicate: ::RDF::Vocab::rdam.modeofissuance do |index|
        index.as :stored_searchable
      end

      property :mods_note, predicate: ::RDF::Vocab::modsrdf.note do |index|
        index.as :stored_searchable
      end

      property :object_orientation, predicate: ::RDF::Vocab::ons.objectOrientation do |index|
        index.as :stored_searchable
      end

      property :original_name_usage, predicate: ::RDF::Vocab::dwcterms.originalNameUsage do |index|
        index.as :stored_searchable
      end

      property :tribal_notes, predicate: ::RDF::Vocab::ons.tribalNotes do |index|
        index.as :stored_searchable
      end

      property :source_condition, predicate: ::RDF::Vocab::ons.sourceCondition do |index|
        index.as :stored_searchable
      end

      property :specimentype, predicate: ::RDF::Vocab::ons.specimenType do |index|
        index.as :stored_searchable
      end

      property :temporal, predicate: ::RDF::Vocab::DC.temporal do |index|
        index.as :stored_searchable
      end

      property :taxon_class, predicate: ::RDF::Vocab::dwcterms.class do |index|
        index.as :stored_searchable, :facetable
      end

      property :cultural_context, predicate: ::RDF::Vocab::ons.vra_culturalContext do |index|
        index.as :stored_searchable, :facetable
      end

      property :ethnographic_term, predicate: ::RDF::Vocab::ons.ethnographic do |index|
        index.as :stored_searchable, :facetable
      end

      property :event, predicate: ::RDF::Vocab::schema.Event do |index|
        index.as :stored_searchable
      end

      property :family, predicate: ::RDF::Vocab::dwcterms.family do |index|
        index.as :stored_searchable, :facetable
      end

      property :genus, predicate: ::RDF::Vocab::dwcterms.genus do |index|
        index.as :stored_searchable, :facetable
      end

      property :order, predicate: ::RDF::Vocab::dwcterms.order do |index|
        index.as :stored_searchable, :facetable
      end

      property :species, predicate: ::RDF::Vocab::dwcterms.specificEpithet do |index|
        index.as :stored_searchable, :facetable
      end

      property :subject, predicate: ::RDF::Vocab::dce.subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :military_branch, predicate: ::RDF::Vocab::ons.militaryBranch do |index|
        index.as :stored_searchable, :facetable
      end

      property :phylum_or_division, predicate: ::RDF::Vocab::dwcterms.phylum do |index|
        index.as :stored_searchable, :facetable
      end

      property :sports_team, predicate: ::RDF::Vocab::ons.sportsTeam do |index|
        index.as :stored_searchable
      end

      property :state_or_edition, predicate: ::RDF::Vocab::ons.vra_stateEdition do |index|
        index.as :stored_searchable
      end

      property :style_or_period, predicate: ::RDF::Vocab::ons.vra_hasStylePeriod do |index|
        index.as :stored_searchable, :facetable
      end

      property :lc_subject, predicate: ::RDF::Vocab::DC.subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :tribal_classes, predicate: ::RDF::Vocab::ons.tribalClasses do |index|
        index.as :stored_searchable
      end

      property :tribal_terms, predicate: ::RDF::Vocab::ons.tribalTerms do |index|
        index.as :stored_searchable
      end

      property :common_name, predicate: ::RDF::Vocab::dwcterms.vernacularName do |index|
        index.as :stored_searchable
      end

      property :scientific_name_authorship, predicate: ::RDF::Vocab::dwcterms.scientificNameAuthorship do |index|
        index.as :stored_searchable
      end

      property :higher_classification, predicate: ::RDF::Vocab::dwcterms.higherClassification do |index|
        index.as :stored_searchable
      end

      property :identification_verification_status, predicate: ::RDF::Vocab::dwcterms.identificationVerificationStatus do |index|
        index.as :stored_searchable
      end

      property :award, predicate: ::RDF::Vocab::schema.award do |index|
        index.as :stored_searchable
      end

      property :legal_name, predicate: ::RDF::Vocab::schema.legalName do |index|
        index.as :stored_searchable
      end

      property :box_name, predicate: ::RDF::Vocab::ons.boxName do |index|
        index.as :stored_searchable, :facetable
      end

      property :box_number, predicate: ::RDF::Vocab::ons.boxNumber do |index|
        index.as :stored_searchable
      end

      property :citation, predicate: ::RDF::Vocab::schema.citation do |index|
        index.as :stored_searchable
      end

      property :current_repository_id, predicate: ::RDF::Vocab::ons.vra_idCurrentRepository do |index|
        index.as :stored_searchable
      end

      property :folder_name, predicate: ::RDF::Vocab::ons.folderName do |index|
        index.as :stored_searchable, :facetable
      end

      property :folder_number, predicate: ::RDF::Vocab::ons.folderNumber do |index|
        index.as :stored_searchable, :facetable
      end

      property :local_collection_id, predicate: ::RDF::Vocab::ons.localCollectionID do |index|
        index.as :stored_searchable
      end

      property :local_collection_name, predicate: ::RDF::Vocab::ons.localCollectionName do |index|
        index.as :stored_searchable, :facetable
      end

      property :location_copyshelf_location, predicate: ::RDF::Vocab::modsrdf.locationCopyShelfLocator do |index|
        index.as :stored_searchable
      end

      property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
        index.as :stored_searchable, :facetable
      end

      property :language, predicate: ::RDF::Vocab::DC.language do |index|
        index.as :stored_searchable, :facetable
      end

      property :place_of_production, predicate: ::RDF::Vocab::rdam.placeOfProduction.en do |index|
        index.as :stored_searchable
      end

      property :provenance, predicate: ::RDF::Vocab::DC.provenance do |index|
        index.as :stored_searchable
      end

      property :publication_place, predicate: ::RDF::Vocab::marcrel.pup do |index|
        index.as :stored_searchable
      end

      property :repository, predicate: ::RDF::Vocab::marcrel.rps do |index|
        index.as :stored_searchable, :facetable
      end

      property :source, predicate: ::RDF::Vocab::DC.source do |index|
        index.as :stored_searchable
      end

      property :series_name, predicate: ::RDF::Vocab::ons.seriesName do |index|
        index.as :stored_searchable, :facetable
      end

      property :series_number, predicate: ::RDF::Vocab::ons.seriesNumber do |index|
        index.as :stored_searchable, :facetable
      end

      property :art_series, predicate: ::RDF::Vocab::ons.artSeries do |index|
        index.as :stored_searchable
      end

      property :has_finding_aid, predicate: ::RDF::Vocab::oad.has_findingAid do |index|
        index.as :stored_searchable
      end

      property :has_part, predicate: ::RDF::Vocab::DC.hasPart do |index|
        index.as :stored_searchable
      end

      property :has_version, predicate: ::RDF::Vocab::DC.hasVersion do |index|
        index.as :stored_searchable
      end

      property :is_part_of, predicate: ::RDF::Vocab::DC.isPartOf do |index|
        index.as :stored_searchable
      end

      property :is_version_of, predicate: ::RDF::Vocab::DC.isVersionOf do |index|
        index.as :stored_searchable
      end

      property :has_part, predicate: ::RDF::Vocab::DC.hasPart do |index|
        index.as :stored_searchable, :facetable
      end

      property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
        index.as :stored_searchable, :facetable
      end

      property :type, predicate: ::RDF::Vocab::DC.type do |index|
        index.as :stored_searchable, :facetable
      end

      property :work_type, predicate: ::RDF::Vocab::rdf.type do |index|
        index.as :stored_searchable, :facetable
      end

      property :extent, predicate: ::RDF::Vocab::DC.extent do |index|
        index.as :stored_searchable
      end

      property :format, predicate: ::RDF::Vocab::DC.format do |index|
        index.as :stored_searchable, :facetable
      end

      property :material, predicate: ::RDF::Vocab::ons.vra_material do |index|
        index.as :stored_searchable
      end

      property :measurements, predicate: ::RDF::Vocab::ons.vra_measurements do |index|
        index.as :stored_searchable
      end

      property :physical_extent, predicate: ::RDF::Vocab::modsrdf.physicalExtent do |index|
        index.as :stored_searchable
      end

      property :technique, predicate: ::RDF::Vocab::DC.ons.vra_hasTechnique do |index|
        index.as :stored_searchable
      end

      property :exhibit, predicate: ::RDF::Vocab::ons.exhibit do |index|
        index.as :stored_searchable, :facetable
      end

      property :primary_set, predicate: ::RDF::Vocab::ons.primarySet do |index|
        index.as :stored_searchable
      end

      property :set, predicate: ::RDF::Vocab::ons.set do |index|
        index.as :stored_searchable, :facetable
      end

      property :conversion, predicate: ::RDF::Vocab::ons.conversionSpecifications do |index|
        index.as :stored_searchable
      end

      property :copy_location, predicate: ::RDF::Vocab::modsrdf.locationCopySublocation do |index|
        index.as :stored_searchable
      end

      property :date_digitized, predicate: ::RDF::Vocab::ons.dateDigitized do |index|
        index.as :stored_searchable
      end

      property :file_size, predicate: ::RDF::Vocab::rdam.filesize do |index|
        index.as :stored_searchable
      end

      property :institution, predicate: ::RDF::Vocab::ons.contributingInstitution do |index|
        index.as :stored_searchable, :facetable
      end

      property :modified, predicate: ::RDF::Vocab::DC.modified do |index|
        index.as :stored_searchable
      end

      property :replaces_url, predicate: ::RDF::Vocab::DC.replaces do |index|
        index.as :stored_searchable
      end

      property :submission_date, predicate: ::RDF::Vocab::DC.submitted do |index|
        index.as :stored_searchable
      end

      property :box, predicate: ::RDF::Vocab::schema.box do |index|
        index.as :stored_searchable
      end

      property :gps_latitude, predicate: ::RDF::Vocab::exif.gpsLatitude do |index|
        index.as :stored_searchable
      end

      property :gps_longitude, predicate: ::RDF::Vocab::exif.gpsLongitude do |index|
        index.as :stored_searchable
      end

      property :location, predicate: ::RDF::Vocab::DC.spatial do |index|
        index.as :stored_searchable, :facetable
      end

      property :street_address, predicate: ::RDF::Vocab::madsrdf.streetAddress do |index|
        index.as :stored_searchable
      end

      property :ranger_district, predicate: ::RDF::Vocab::ons.rangerDistrict do |index|
        index.as :stored_searchable, :facetable
      end

      property :tgn, predicate: ::RDF::Vocab::ons.tgn do |index|
        index.as :stored_searchable, :facetable
      end

      property :water_basin, predicate: ::RDF::Vocab::ons.waterBasin do |index|
        index.as :stored_searchable, :facetable
      end

      property :award_date, predicate: ::RDF::Vocab::ons.awardDate do |index|
        index.as :stored_searchable, :facetable
      end

      property :created, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      property :collected_date, predicate: ::RDF::Vocab::ons.collectedDate do |index|
        index.as :stored_searchable
      end

      property :date, predicate: ::RDF::Vocab::DC.date do |index|
        index.as :stored_searchable
      end

      property :issued, predicate: ::RDF::Vocab::DC.issued do |index|
        index.as :stored_searchable
      end

      property :view_date, predicate: ::RDF::Vocab::ons.cco_viewDate do |index|
        index.as :stored_searchable
      end

      property :acquisition_date, predicate: ::RDF::Vocab::ons.acquisitionDate do |index|
        index.as :stored_searchable
      end

      property :accession_number, predicate: ::RDF::Vocab::ons.cco_accessionNumber do |index|
        index.as :stored_searchable
      end

      property :barcode, predicate: ::RDF::Vocab::bf.barcode do |index|
        index.as :stored_searchable
      end

      property :hydrologic_unit_code, predicate: ::RDF::Vocab::ons.hydrologicUnitCode do |index|
        index.as :stored_searchable
      end

      property :item_locator, predicate: ::RDF::Vocab::holding.label do |index|
        index.as :stored_searchable
      end

      property :longitude_latitude_identification, predicate: ::RDF::Vocab::ons.llid do |index|
        index.as :stored_searchable
      end

      property :copyright_claimant, predicate: ::RDF::Vocab::marcrel.cpc do |index|
        index.as :stored_searchable
      end

      property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
        index.as :stored_searchable, :facetable
      end

      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
        index.as :stored_searchable
      end

      property :license, predicate: ::RDF::Vocab::cc.License do |index|
        index.as :stored_searchable, :facetable
      end

      property :use_restrictions, predicate: ::RDF::Vocab::locah.useRestrictions do |index|
        index.as :stored_searchable
      end

      property :access_restrictions, predicate: ::RDF::Vocab::locah.accessRestrictions do |index|
        index.as :stored_searchable
      end
    end
  end
end