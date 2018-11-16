module OD2
  module GenericMetadata
    extend ActiveSupport::Concern

    # Usage notes and expectatiONS can be found in the Metadata Application Profile:
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

      property :arranger, predicate: ::RDF::Vocab::MARCREL.arr do |index|
        index.as :stored_searchable, :facetable
      end

      property :artist, predicate: ::RDF::Vocab::MARCREL.art do |index|
        index.as :stored_searchable, :facetable
      end

      property :author, predicate: ::RDF::Vocab::MARCREL.aut do |index|
        index.as :stored_searchable, :facetable
      end

      property :cartographer, predicate: ::RDF::Vocab::MARCREL.ctg do |index|
        index.as :stored_searchable, :facetable
      end

      property :collector, predicate: ::RDF::Vocab::MARCREL.col do |index|
        index.as :stored_searchable, :facetable
      end

      property :composer, predicate: ::RDF::Vocab::MARCREL.cmp do |index|
        index.as :stored_searchable, :facetable
      end

      property :creator_display, predicate: ::RDF::Vocab::ONS.cco_creatorDisplay do |index|
        index.as :stored_searchable, :facetable
      end

      property :dedicatee, predicate: ::RDF::Vocab::MARCREL.dte do |index|
        index.as :stored_searchable, :facetable
      end

      property :donor, predicate: ::RDF::Vocab::MARCREL.dnr do |index|
        index.as :stored_searchable, :facetable
      end

      property :designer, predicate: ::RDF::Vocab::MARCREL.dsr do |index|
        index.as :stored_searchable, :facetable
      end

      property :editor, predicate: ::RDF::Vocab::MARCREL.edt do |index|
        index.as :stored_searchable, :facetable
      end

      property :former_owner, predicate: ::RDF::Vocab::MARCREL.fmo do |index|
        index.as :stored_searchable, :facetable
      end

      property :illustrator, predicate: ::RDF::Vocab::MARCREL.ill do |index|
        index.as :stored_searchable, :facetable
      end

      property :interviewee, predicate: ::RDF::Vocab::MARCREL.ive do |index|
        index.as :stored_searchable, :facetable
      end

      property :interviewer, predicate: ::RDF::Vocab::MARCREL.ivr do |index|
        index.as :stored_searchable, :facetable
      end

      property :lyricist, predicate: ::RDF::Vocab::MARCREL.lyr do |index|
        index.as :stored_searchable, :facetable
      end

      property :owner, predicate: ::RDF::Vocab::MARCREL.own do |index|
        index.as :stored_searchable, :facetable
      end

      property :patron, predicate: ::RDF::Vocab::MARCREL.pat do |index|
        index.as :stored_searchable, :facetable
      end

      property :photographer, predicate: ::RDF::Vocab::MARCREL.pht do |index|
        index.as :stored_searchable, :facetable
      end

      property :print_maker, predicate: ::RDF::Vocab::MARCREL.prm do |index|
        index.as :stored_searchable, :facetable
      end

      property :recipient, predicate: ::RDF::Vocab::MARCREL.rcp do |index|
        index.as :stored_searchable, :facetable
      end

      property :scribe, predicate: ::RDF::Vocab::MARCREL.scr do |index|
        index.as :stored_searchable, :facetable
      end

      property :transcriber, predicate: ::RDF::Vocab::MARCREL.trc do |index|
        index.as :stored_searchable, :facetable
      end

      property :translator, predicate: ::RDF::Vocab::MARCREL.trl do |index|
        index.as :stored_searchable, :facetable
      end

      property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
        index.as :stored_searchable
      end

      property :accepted_name_usage, predicate: ::RDF::Vocab::DWCTERMS.acceptedNameUsage do |index|
        index.as :stored_searchable
      end

      property :biographical_information, predicate: ::RDF::Vocab::RDAA.biographicalinformation do |index|
        index.as :stored_searchable
      end

      property :canzoniere_poems, predicate: ::RDF::Vocab::ONS.canzonierePoems do |index|
        index.as :stored_searchable
      end

      property :compass_direction, predicate: ::RDF::Vocab::ONS.compassDirection do |index|
        index.as :stored_searchable
      end

      property :contents, predicate: ::RDF::Vocab::ONS.contents do |index|
        index.as :stored_searchable
      end

      property :cover_description, predicate: ::RDF::Vocab::ONS.coverDescription do |index|
        index.as :stored_searchable
      end

      property :cover, predicate: ::RDF::Vocab::DCE.cover do |index|
        index.as :stored_searchable
      end

      property :description_of_manifestation, predicate: ::RDF::Vocab::RDAM.descriptionofmanifestation do |index|
        index.as :stored_searchable
      end

      property :form_of_work, predicate: ::RDF::Vocab::RDAW.formofwork do |index|
        index.as :stored_searchable
      end

      property :identification_verification_status, predicate: ::RDF::Vocab::DWCTERMS.identificationVerificatiOnStatus do |index|
        index.as :stored_searchable
      end

      property :inscription, predicate: ::RDF::Vocab::ONS.vra_inscription do |index|
        index.as :stored_searchable
      end

      property :layout, predicate: ::RDF::Vocab::RDAM.P30155 do |index|
        index.as :stored_searchable
      end

      property :military_highest_rank, predicate: ::RDF::Vocab::ONS.militaryHighestRank do |index|
        index.as :stored_searchable
      end

      property :military_occupation, predicate: ::RDF::Vocab::ONS.militaryOccupation do |index|
        index.as :stored_searchable
      end

      property :military_service_location, predicate: ::RDF::Vocab::ONS.militaryServiceLocation do |index|
        index.as :stored_searchable
      end

      property :mode_of_issuance, predicate: ::RDF::Vocab::RDAM.modeofissuance do |index|
        index.as :stored_searchable
      end

      property :mods_note, predicate: ::RDF::Vocab::MODSRDF.note do |index|
        index.as :stored_searchable
      end

      property :object_orientation, predicate: ::RDF::Vocab::ONS.objectOrientation do |index|
        index.as :stored_searchable
      end

      property :original_name_usage, predicate: ::RDF::Vocab::DWCTERMS.originalNameUsage do |index|
        index.as :stored_searchable
      end

      property :tribal_notes, predicate: ::RDF::Vocab::ONS.tribalNotes do |index|
        index.as :stored_searchable
      end

      property :source_condition, predicate: ::RDF::Vocab::ONS.sourceCondition do |index|
        index.as :stored_searchable
      end

      property :specimentype, predicate: ::RDF::Vocab::ONS.specimenType do |index|
        index.as :stored_searchable
      end

      property :temporal, predicate: ::RDF::Vocab::DC.temporal do |index|
        index.as :stored_searchable
      end

      property :taxon_class, predicate: ::RDF::Vocab::DWCTERMS.class do |index|
        index.as :stored_searchable, :facetable
      end

      property :cultural_context, predicate: ::RDF::Vocab::ONS.vra_culturalContext do |index|
        index.as :stored_searchable, :facetable
      end

      property :ethnographic_term, predicate: ::RDF::Vocab::ONS.ethnographic do |index|
        index.as :stored_searchable, :facetable
      end

      property :event, predicate: ::RDF::Vocab::SCHEMA.Event do |index|
        index.as :stored_searchable
      end

      property :family, predicate: ::RDF::Vocab::DWCTERMS.family do |index|
        index.as :stored_searchable, :facetable
      end

      property :genus, predicate: ::RDF::Vocab::DWCTERMS.genus do |index|
        index.as :stored_searchable, :facetable
      end

      property :order, predicate: ::RDF::Vocab::DWCTERMS.order do |index|
        index.as :stored_searchable, :facetable
      end

      property :species, predicate: ::RDF::Vocab::DWCTERMS.specificEpithet do |index|
        index.as :stored_searchable, :facetable
      end

      property :subject, predicate: ::RDF::Vocab::DCE.subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :military_branch, predicate: ::RDF::Vocab::ONS.militaryBranch do |index|
        index.as :stored_searchable, :facetable
      end

      property :phylum_or_division, predicate: ::RDF::Vocab::dwcterms.phylum do |index|
        index.as :stored_searchable, :facetable
      end

      property :sports_team, predicate: ::RDF::Vocab::ONS.sportsTeam do |index|
        index.as :stored_searchable
      end

      property :state_or_edition, predicate: ::RDF::Vocab::ONS.vra_stateEdition do |index|
        index.as :stored_searchable
      end

      property :style_or_period, predicate: ::RDF::Vocab::ONS.vra_hasStylePeriod do |index|
        index.as :stored_searchable, :facetable
      end

      property :lc_subject, predicate: ::RDF::Vocab::DC.subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :tribal_classes, predicate: ::RDF::Vocab::ONS.tribalClasses do |index|
        index.as :stored_searchable
      end

      property :tribal_terms, predicate: ::RDF::Vocab::ONS.tribalTerms do |index|
        index.as :stored_searchable
      end

      property :common_name, predicate: ::RDF::Vocab::DWCTERMS.vernacularName do |index|
        index.as :stored_searchable
      end

      property :scientific_name_authorship, predicate: ::RDF::Vocab::DWCTERMS.scientificNameAuthorship do |index|
        index.as :stored_searchable
      end

      property :higher_classification, predicate: ::RDF::Vocab::DWCTERMS.higherClassification do |index|
        index.as :stored_searchable
      end

      property :identification_verification_status, predicate: ::RDF::Vocab::DWCTERMS.identificationVerificatiOnStatus do |index|
        index.as :stored_searchable
      end

      property :award, predicate: ::RDF::Vocab::SCHEMA.award do |index|
        index.as :stored_searchable
      end

      property :legal_name, predicate: ::RDF::Vocab::SCHEMA.legalName do |index|
        index.as :stored_searchable
      end

      property :box_name, predicate: ::RDF::Vocab::ONS.boxName do |index|
        index.as :stored_searchable, :facetable
      end

      property :box_number, predicate: ::RDF::Vocab::ONS.boxNumber do |index|
        index.as :stored_searchable
      end

      property :citation, predicate: ::RDF::Vocab::SCHEMA.citation do |index|
        index.as :stored_searchable
      end

      property :current_repository_id, predicate: ::RDF::Vocab::ONS.vra_idCurrentRepository do |index|
        index.as :stored_searchable
      end

      property :folder_name, predicate: ::RDF::Vocab::ONS.folderName do |index|
        index.as :stored_searchable, :facetable
      end

      property :folder_number, predicate: ::RDF::Vocab::ONS.folderNumber do |index|
        index.as :stored_searchable, :facetable
      end

      property :local_collection_id, predicate: ::RDF::Vocab::ONS.localCollectionID do |index|
        index.as :stored_searchable
      end

      property :local_collection_name, predicate: ::RDF::Vocab::ONS.localCollectionName do |index|
        index.as :stored_searchable, :facetable
      end

      property :location_copyshelf_location, predicate: ::RDF::Vocab::MODSRDF.locationCopyShelfLocator do |index|
        index.as :stored_searchable
      end

      property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
        index.as :stored_searchable, :facetable
      end

      property :language, predicate: ::RDF::Vocab::DC.language do |index|
        index.as :stored_searchable, :facetable
      end

      property :place_of_production, predicate: ::RDF::Vocab::RDAM.placeOfProduction.en do |index|
        index.as :stored_searchable
      end

      property :provenance, predicate: ::RDF::Vocab::DC.provenance do |index|
        index.as :stored_searchable
      end

      property :publication_place, predicate: ::RDF::Vocab::MARCREL.pup do |index|
        index.as :stored_searchable
      end

      property :repository, predicate: ::RDF::Vocab::MARCREL.rps do |index|
        index.as :stored_searchable, :facetable
      end

      property :source, predicate: ::RDF::Vocab::DC.source do |index|
        index.as :stored_searchable
      end

      property :series_name, predicate: ::RDF::Vocab::ONS.seriesName do |index|
        index.as :stored_searchable, :facetable
      end

      property :series_number, predicate: ::RDF::Vocab::ONS.seriesNumber do |index|
        index.as :stored_searchable, :facetable
      end

      property :art_series, predicate: ::RDF::Vocab::ONS.artSeries do |index|
        index.as :stored_searchable
      end

      property :has_finding_aid, predicate: ::RDF::Vocab::OAD.has_findingAid do |index|
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

      property :work_type, predicate: ::RDF::Vocab::RDF.type do |index|
        index.as :stored_searchable, :facetable
      end

      property :extent, predicate: ::RDF::Vocab::DC.extent do |index|
        index.as :stored_searchable
      end

      property :format, predicate: ::RDF::Vocab::DC.format do |index|
        index.as :stored_searchable, :facetable
      end

      property :material, predicate: ::RDF::Vocab::ONS.vra_material do |index|
        index.as :stored_searchable
      end

      property :measurements, predicate: ::RDF::Vocab::ONS.vra_measurements do |index|
        index.as :stored_searchable
      end

      property :physical_extent, predicate: ::RDF::Vocab::MODSRDF.physicalExtent do |index|
        index.as :stored_searchable
      end

      property :technique, predicate: ::RDF::Vocab::DC.ONS.vra_hasTechnique do |index|
        index.as :stored_searchable
      end

      property :exhibit, predicate: ::RDF::Vocab::ONS.exhibit do |index|
        index.as :stored_searchable, :facetable
      end

      property :primary_set, predicate: ::RDF::Vocab::ONS.primarySet do |index|
        index.as :stored_searchable
      end

      property :set, predicate: ::RDF::Vocab::ONS.set do |index|
        index.as :stored_searchable, :facetable
      end

      property :conversion, predicate: ::RDF::Vocab::ONS.conversionSpecifications do |index|
        index.as :stored_searchable
      end

      property :copy_location, predicate: ::RDF::Vocab::MODSRDF.locationCopySublocation do |index|
        index.as :stored_searchable
      end

      property :date_digitized, predicate: ::RDF::Vocab::ONS.dateDigitized do |index|
        index.as :stored_searchable
      end

      property :file_size, predicate: ::RDF::Vocab::RDAM.filesize do |index|
        index.as :stored_searchable
      end

      property :institution, predicate: ::RDF::Vocab::ONS.contributingInstitution do |index|
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

      property :box, predicate: ::RDF::Vocab::SCHEMA.box do |index|
        index.as :stored_searchable
      end

      property :gps_latitude, predicate: ::RDF::Vocab::EXIF.gpsLatitude do |index|
        index.as :stored_searchable
      end

      property :gps_longitude, predicate: ::RDF::Vocab::EXIF.gpsLongitude do |index|
        index.as :stored_searchable
      end

      property :location, predicate: ::RDF::Vocab::DC.spatial do |index|
        index.as :stored_searchable, :facetable
      end

      property :street_address, predicate: ::RDF::Vocab::MODSRDF.streetAddress do |index|
        index.as :stored_searchable
      end

      property :ranger_district, predicate: ::RDF::Vocab::ONS.rangerDistrict do |index|
        index.as :stored_searchable, :facetable
      end

      property :tgn, predicate: ::RDF::Vocab::ONS.tgn do |index|
        index.as :stored_searchable, :facetable
      end

      property :water_basin, predicate: ::RDF::Vocab::ONS.waterBasin do |index|
        index.as :stored_searchable, :facetable
      end

      property :award_date, predicate: ::RDF::Vocab::ONS.awardDate do |index|
        index.as :stored_searchable, :facetable
      end

      property :created, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      property :collected_date, predicate: ::RDF::Vocab::ONS.collectedDate do |index|
        index.as :stored_searchable
      end

      property :date, predicate: ::RDF::Vocab::DC.date do |index|
        index.as :stored_searchable
      end

      property :issued, predicate: ::RDF::Vocab::DC.issued do |index|
        index.as :stored_searchable
      end

      property :view_date, predicate: ::RDF::Vocab::ONS.cco_viewDate do |index|
        index.as :stored_searchable
      end

      property :acquisition_date, predicate: ::RDF::Vocab::ONS.acquisitionDate do |index|
        index.as :stored_searchable
      end

      property :accession_number, predicate: ::RDF::Vocab::ONS.cco_accessionNumber do |index|
        index.as :stored_searchable
      end

      property :barcode, predicate: ::RDF::Vocab::BF.barcode do |index|
        index.as :stored_searchable
      end

      property :hydrologic_unit_code, predicate: ::RDF::Vocab::ONS.hydrologicUnitCode do |index|
        index.as :stored_searchable
      end

      property :item_locator, predicate: ::RDF::Vocab::HOLDING.label do |index|
        index.as :stored_searchable
      end

      property :longitude_latitude_identification, predicate: ::RDF::Vocab::ONS.llid do |index|
        index.as :stored_searchable
      end

      property :copyright_claimant, predicate: ::RDF::Vocab::MARCREL.cpc do |index|
        index.as :stored_searchable
      end

      property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
        index.as :stored_searchable, :facetable
      end

      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
        index.as :stored_searchable
      end

      property :license, predicate: ::RDF::Vocab::CC.License do |index|
        index.as :stored_searchable, :facetable
      end

      property :use_restrictions, predicate: ::RDF::Vocab::LOCAH.useRestrictions do |index|
        index.as :stored_searchable
      end

      property :access_restrictions, predicate: ::RDF::Vocab::LOCAH.accessRestrictions do |index|
        index.as :stored_searchable
      end
    end
  end
end