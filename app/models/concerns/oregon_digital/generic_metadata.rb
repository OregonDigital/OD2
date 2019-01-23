# frozen_string_literal:true

module OregonDigital
  # Sets metadata for a generic work
  module GenericMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit#gid=0
    PROPERTIES = %w[abstract accepted_name_usage access_restrictions accession_number acquisition_date alternative arranger art_series artist author award award_date barcode biographical_information box box_name box_number canzoniere_poems cartographer citation collected_date collector common_name compass_direction composer contents contributor conversion copy_location copyright_claimant cover_description coverage creator creator_display cultural_context current_repository_id date date_created date_digitized dedicatee description description_of_manifestation designer donor editor ethnographic_term event exhibit extent family file_size folder_name folder_number form_of_work format former_owner genus gps_latitude gps_longitude has_finding_aid has_part has_version higher_classification hydrologic_unit_code identification_verification_status identifier illustrator inscription institution interviewee interviewer isPartOf is_version_of issued item_locator keyword language layout legal_name license local_collection_id local_collection_name location location_copyshelf_location longitude_latitude_identification lyricist material measurements military_branch military_highest_rank military_occupation military_service_location mode_of_issuance mods_note object_orientation oembed_url order original_name_usage owner patron photographer phylum_or_division physical_extent place_of_production primary_set print_maker provenance publication_place publisher ranger_district recipient relation related_url replaces_url repository resource_type rights_holder rights_statement scientific_name_authorship scribe series_name series_number set source source_condition species specimen_type sports_team state_or_edition street_address style_or_period subject taxon_class technique temporal tgn transcriber translator tribal_classes tribal_notes tribal_terms tribal_title use_restrictions view_date water_basin workType].freeze

    included do
      property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false
      property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false
      property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
      property :resource_type, predicate: ::RDF::Vocab::DC.type
      property :creator, predicate: ::RDF::Vocab::DC11.creator
      property :contributor, predicate: ::RDF::Vocab::DC11.contributor
      property :date_created, predicate: ::RDF::Vocab::DC.created
      property :related_url, predicate: ::RDF::RDFS.seeAlso

      property :description, predicate: ::RDF::Vocab::DC.description do |index|
        index.as :stored_searchable
      end

      property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
      property :identifier, predicate: ::RDF::Vocab::DC.identifier

      property :alternative, predicate: ::RDF::Vocab::DC.alternative do |index|
        index.as :stored_searchable
      end

      property :tribal_title, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/tribalTitle') do |index|
        index.as :stored_searchable
      end

      property :arranger, predicate: ::RDF::Vocab::MARCRelators.arr do |index|
        index.as :stored_searchable, :facetable
      end

      property :artist, predicate: ::RDF::Vocab::MARCRelators.art do |index|
        index.as :stored_searchable, :facetable
      end

      property :author, predicate: ::RDF::Vocab::MARCRelators.aut do |index|
        index.as :stored_searchable, :facetable
      end

      property :cartographer, predicate: ::RDF::Vocab::MARCRelators.ctg do |index|
        index.as :stored_searchable, :facetable
      end

      property :collector, predicate: ::RDF::Vocab::MARCRelators.col do |index|
        index.as :stored_searchable, :facetable
      end

      property :composer, predicate: ::RDF::Vocab::MARCRelators.cmp do |index|
        index.as :stored_searchable, :facetable
      end

      property :creator_display, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/cco_creatorDisplay') do |index|
        index.as :stored_searchable, :facetable
      end

      property :dedicatee, predicate: ::RDF::Vocab::MARCRelators.dte do |index|
        index.as :stored_searchable, :facetable
      end

      property :donor, predicate: ::RDF::Vocab::MARCRelators.dnr do |index|
        index.as :stored_searchable, :facetable
      end

      property :designer, predicate: ::RDF::Vocab::MARCRelators.dsr do |index|
        index.as :stored_searchable, :facetable
      end

      property :editor, predicate: ::RDF::Vocab::MARCRelators.edt do |index|
        index.as :stored_searchable, :facetable
      end

      property :former_owner, predicate: ::RDF::Vocab::MARCRelators.fmo do |index|
        index.as :stored_searchable, :facetable
      end

      property :illustrator, predicate: ::RDF::Vocab::MARCRelators.ill do |index|
        index.as :stored_searchable, :facetable
      end

      property :interviewee, predicate: ::RDF::Vocab::MARCRelators.ive do |index|
        index.as :stored_searchable, :facetable
      end

      property :interviewer, predicate: ::RDF::Vocab::MARCRelators.ivr do |index|
        index.as :stored_searchable, :facetable
      end

      property :lyricist, predicate: ::RDF::Vocab::MARCRelators.lyr do |index|
        index.as :stored_searchable, :facetable
      end

      property :owner, predicate: ::RDF::Vocab::MARCRelators.own, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :patron, predicate: ::RDF::Vocab::MARCRelators.pat do |index|
        index.as :stored_searchable, :facetable
      end

      property :photographer, predicate: ::RDF::Vocab::MARCRelators.pht do |index|
        index.as :stored_searchable, :facetable
      end

      property :print_maker, predicate: ::RDF::Vocab::MARCRelators.prm do |index|
        index.as :stored_searchable, :facetable
      end

      property :recipient, predicate: ::RDF::Vocab::MARCRelators.rcp do |index|
        index.as :stored_searchable, :facetable
      end

      property :scribe, predicate: ::RDF::Vocab::MARCRelators.scr do |index|
        index.as :stored_searchable, :facetable
      end

      property :transcriber, predicate: ::RDF::Vocab::MARCRelators.trc do |index|
        index.as :stored_searchable, :facetable
      end

      property :translator, predicate: ::RDF::Vocab::MARCRelators.trl do |index|
        index.as :stored_searchable, :facetable
      end

      property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
        index.as :stored_searchable
      end

      property :accepted_name_usage, predicate: ::RDF::Vocab::DWC.acceptedNameUsage do |index|
        index.as :stored_searchable
      end

      property :biographical_information, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/a/biographicalInformation') do |index|
        index.as :stored_searchable
      end

      property :canzoniere_poems, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/canzonierePoems') do |index|
        index.as :stored_searchable
      end

      property :compass_direction, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/compassDirection') do |index|
        index.as :stored_searchable
      end

      property :contents, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/contents') do |index|
        index.as :stored_searchable
      end

      property :cover_description, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/coverDescription') do |index|
        index.as :stored_searchable
      end

      property :coverage, predicate: ::RDF::Vocab::DC11.coverage do |index|
        index.as :stored_searchable
      end

      property :description_of_manifestation, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/w/descriptionOfManifestation') do |index|
        index.as :stored_searchable
      end

      property :form_of_work, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/w/formOfWork') do |index|
        index.as :stored_searchable
      end

      property :identification_verification_status, predicate: ::RDF::Vocab::DWC.identificationVerificationStatus, multiple: false do |index|
        index.as :stored_searchable
      end

      property :inscription, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/vra_inscription') do |index|
        index.as :stored_searchable
      end

      property :layout, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/m/P30155') do |index|
        index.as :stored_searchable
      end

      property :military_highest_rank, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/militaryHighestRank'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :military_occupation, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/militaryOccupation') do |index|
        index.as :stored_searchable
      end

      property :military_service_location, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/militaryServiceLocation') do |index|
        index.as :stored_searchable
      end

      property :mode_of_issuance, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/m/modeOfIssuance') do |index|
        index.as :stored_searchable
      end

      property :mods_note, predicate: ::RDF::Vocab::MODS.note do |index|
        index.as :stored_searchable
      end

      property :object_orientation, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/objectOrientation'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :original_name_usage, predicate: ::RDF::Vocab::DWC.originalNameUsage do |index|
        index.as :stored_searchable
      end

      property :tribal_notes, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/tribalNotes') do |index|
        index.as :stored_searchable
      end

      property :source_condition, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/sourceCondition') do |index|
        index.as :stored_searchable
      end

      property :specimen_type, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/specimenType'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :temporal, predicate: ::RDF::Vocab::DC.temporal do |index|
        index.as :stored_searchable
      end

      property :taxon_class, predicate: ::RDF::Vocab::DWC.class do |index|
        index.as :stored_searchable, :facetable
      end

      property :cultural_context, predicate: ::RDF::URI.new('http://purl.org/vra/culturalContext') do |index|
        index.as :stored_searchable, :facetable
      end

      property :ethnographic_term, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/ethnographic') do |index|
        index.as :stored_searchable, :facetable
      end

      property :event, predicate: ::RDF::Vocab::SCHEMA.Event do |index|
        index.as :stored_searchable
      end

      property :family, predicate: ::RDF::Vocab::DWC.family do |index|
        index.as :stored_searchable, :facetable
      end

      property :genus, predicate: ::RDF::Vocab::DWC.genus do |index|
        index.as :stored_searchable, :facetable
      end

      property :order, predicate: ::RDF::Vocab::DWC.order do |index|
        index.as :stored_searchable, :facetable
      end

      property :species, predicate: ::RDF::Vocab::DWC.specificEpithet do |index|
        index.as :stored_searchable, :facetable
      end

      property :keyword, predicate: ::RDF::Vocab::DC11.subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :military_branch, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/militaryBranch') do |index|
        index.as :stored_searchable, :facetable
      end

      property :phylum_or_division, predicate: ::RDF::Vocab::DWC.phylum do |index|
        index.as :stored_searchable, :facetable
      end

      property :sports_team, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/sportsTeam') do |index|
        index.as :stored_searchable
      end

      property :state_or_edition, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/vra_stateEdition') do |index|
        index.as :stored_searchable
      end

      property :style_or_period, predicate: ::RDF::URI.new('http://purl.org/vra/StylePeriod') do |index|
        index.as :stored_searchable, :facetable
      end

      property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :tribal_classes, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/tribalClasses') do |index|
        index.as :stored_searchable
      end

      property :tribal_terms, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/tribalTerms') do |index|
        index.as :stored_searchable
      end

      property :common_name, predicate: ::RDF::Vocab::DWC.vernacularName do |index|
        index.as :stored_searchable
      end

      property :scientific_name_authorship, predicate: ::RDF::Vocab::DWC.scientificNameAuthorship do |index|
        index.as :stored_searchable
      end

      property :higher_classification, predicate: ::RDF::Vocab::DWC.higherClassification do |index|
        index.as :stored_searchable
      end

      property :award, predicate: ::RDF::Vocab::SCHEMA.award do |index|
        index.as :stored_searchable
      end

      property :legal_name, predicate: ::RDF::Vocab::SCHEMA.legalName do |index|
        index.as :stored_searchable
      end

      property :box_name, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/boxName') do |index|
        index.as :stored_searchable, :facetable
      end

      property :box_number, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/boxNumber') do |index|
        index.as :stored_searchable
      end

      property :citation, predicate: ::RDF::Vocab::SCHEMA.citation do |index|
        index.as :stored_searchable
      end

      property :current_repository_id, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/vra_idCurrentRepository') do |index|
        index.as :stored_searchable
      end

      property :folder_name, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/folderName') do |index|
        index.as :stored_searchable, :facetable
      end

      property :folder_number, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/folderNumber') do |index|
        index.as :stored_searchable, :facetable
      end

      property :local_collection_id, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/localCollectionID') do |index|
        index.as :stored_searchable
      end

      property :local_collection_name, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/localCollectionName') do |index|
        index.as :stored_searchable, :facetable
      end

      property :location_copyshelf_location, predicate: ::RDF::Vocab::MODS.locationCopyShelfLocator do |index|
        index.as :stored_searchable
      end

      property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
        index.as :stored_searchable, :facetable
      end

      property :language, predicate: ::RDF::Vocab::DC.language do |index|
        index.as :stored_searchable, :facetable
      end

      property :place_of_production, predicate: ::RDF::URI.new('http://www.rdaregistry.info/Elements/u/placeOfProduction') do |index|
        index.as :stored_searchable
      end

      property :provenance, predicate: ::RDF::Vocab::DC.provenance do |index|
        index.as :stored_searchable
      end

      property :publication_place, predicate: ::RDF::Vocab::MARCRelators.pup do |index|
        index.as :stored_searchable
      end

      property :repository, predicate: ::RDF::Vocab::MARCRelators.rps, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :source, predicate: ::RDF::Vocab::DC.source do |index|
        index.as :stored_searchable
      end

      property :series_name, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/seriesName') do |index|
        index.as :stored_searchable, :facetable
      end

      property :series_number, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/seriesNumber') do |index|
        index.as :stored_searchable, :facetable
      end

      property :art_series, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/artSeries') do |index|
        index.as :stored_searchable
      end

      property :has_finding_aid, predicate: ::RDF::URI.new('http://lod.xdams.org/reload/oad/has_findingAid') do |index|
        index.as :stored_searchable
      end

      property :has_part, predicate: ::RDF::Vocab::DC.hasPart do |index|
        index.as :stored_searchable
      end

      property :has_version, predicate: ::RDF::Vocab::DC.hasVersion do |index|
        index.as :stored_searchable
      end

      property :isPartOf, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/isPartOf') do |index|
        index.as :stored_searchable
      end

      property :is_version_of, predicate: ::RDF::Vocab::DC.isVersionOf do |index|
        index.as :stored_searchable
      end

      property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
        index.as :stored_searchable, :facetable
      end

      property :workType, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/workType') do |index|
        index.as :stored_searchable, :facetable
      end

      property :extent, predicate: ::RDF::Vocab::DC.extent do |index|
        index.as :stored_searchable
      end

      property :format, predicate: ::RDF::Vocab::DC.format do |index|
        index.as :stored_searchable, :facetable
      end

      property :material, predicate: ::RDF::URI.new('http://purl.org/vra/material') do |index|
        index.as :stored_searchable
      end

      property :measurements, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/vra_measurements') do |index|
        index.as :stored_searchable
      end

      property :physical_extent, predicate: ::RDF::Vocab::MODS.physicalExtent do |index|
        index.as :stored_searchable
      end

      property :technique, predicate: ::RDF::URI.new('http://purl.org/vra/hasTechnique') do |index|
        index.as :stored_searchable
      end

      property :exhibit, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/exhibit') do |index|
        index.as :stored_searchable, :facetable
      end

      property :primary_set, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/primarySet'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :set, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/set') do |index|
        index.as :stored_searchable, :facetable
      end

      property :conversion, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/conversionSpecifications') do |index|
        index.as :stored_searchable
      end

      property :copy_location, predicate: ::RDF::Vocab::MODS.locationCopySublocation do |index|
        index.as :stored_searchable
      end

      property :date_digitized, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/dateDigitized'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :file_size, predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/m/filesize'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :institution, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/contributingInstitution') do |index|
        index.as :stored_searchable, :facetable
      end

      property :replaces_url, predicate: ::RDF::Vocab::DC.replaces, multiple: false do |index|
        index.as :stored_searchable
      end

      property :box, predicate: ::RDF::Vocab::SCHEMA.box do |index|
        index.as :stored_searchable
      end

      property :gps_latitude, predicate: ::RDF::Vocab::EXIF.gpsLatitude, multiple: false do |index|
        index.as :stored_searchable
      end

      property :gps_longitude, predicate: ::RDF::Vocab::EXIF.gpsLongitude, multiple: false do |index|
        index.as :stored_searchable
      end

      property :location, predicate: ::RDF::Vocab::DC.spatial do |index|
        index.as :stored_searchable, :facetable
      end

      property :street_address, predicate: ::RDF::Vocab::MADS.streetAddress do |index|
        index.as :stored_searchable
      end

      property :ranger_district, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/rangerDistrict') do |index|
        index.as :stored_searchable, :facetable
      end

      property :tgn, predicate: ::RDF::URI.new('http://dbpedia.org/ontology/HistoricPlace') do |index|
        index.as :stored_searchable, :facetable
      end

      property :water_basin, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/waterBasin') do |index|
        index.as :stored_searchable, :facetable
      end

      property :award_date, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/awardDate') do |index|
        index.as :stored_searchable, :facetable
      end

      property :collected_date, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/collectedDate') do |index|
        index.as :stored_searchable
      end

      property :date, predicate: ::RDF::Vocab::DC.date do |index|
        index.as :stored_searchable
      end

      property :issued, predicate: ::RDF::Vocab::DC.issued do |index|
        index.as :stored_searchable
      end

      property :view_date, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/cco_viewDate') do |index|
        index.as :stored_searchable
      end

      property :acquisition_date, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/acquisitionDate') do |index|
        index.as :stored_searchable
      end

      property :accession_number, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/cco_accessionNumber') do |index|
        index.as :stored_searchable
      end

      property :barcode, predicate: ::RDF::Vocab::Bibframe.barcode do |index|
        index.as :stored_searchable
      end

      property :hydrologic_unit_code, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/hydrologicUnitCode') do |index|
        index.as :stored_searchable
      end

      property :item_locator, predicate: ::RDF::URI.new('http://purl.org/ontology/holding') do |index|
        index.as :stored_searchable
      end

      property :longitude_latitude_identification, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/llid') do |index|
        index.as :stored_searchable
      end

      property :copyright_claimant, predicate: ::RDF::Vocab::MARCRelators.cpc do |index|
        index.as :stored_searchable
      end

      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
        index.as :stored_searchable
      end

      property :license, predicate: ::RDF::Vocab::CC.License do |index|
        index.as :stored_searchable, :facetable
      end

      property :use_restrictions, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/useRestrictions') do |index|
        index.as :stored_searchable
      end

      property :access_restrictions, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/accessRestrictions'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :oembed_url, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/oembed'), multiple: false do |index|
        index.as :facetable
      end

      property :based_near, predicate: ::RDF::Vocab::FOAF.based_near, class_name: Hyrax::ControlledVocabularies::Location

      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:based_near]
      accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true
    end
  end
end
