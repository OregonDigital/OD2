# frozen_string_literal:true

module OregonDigital
  # Sets metadata for a generic work
  module CollectionMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/16xBFjmeSsaN0xQrbOpQ_jIOeFZk3ZM9kmB8CU3IhP2c/edit#gid=0

    included do
      initial_properties = properties.keys
      property :alternative_title, predicate: ::RDF::Vocab::DC.alternative
      property :related_url, predicate: ::RDF::RDFS.seeAlso
      property :resource_type, predicate: ::RDF::Vocab::DC.type, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      property :description, advance_search: true, predicate: ::RDF::Vocab::DC.description do |index|
        index.as :stored_searchable
      end

      property :language, advance_search: false, predicate: ::RDF::Vocab::DC.language do |index|
        index.as :stored_searchable, :facetable
      end

      property :date, predicate: ::RDF::Vocab::DC.date do |index|
        index.as :stored_searchable
      end

      property :has_finding_aid, predicate: RDF::URI.new('http://lod.xdams.org/reload/oad/has_findingAid'), multiple: true, basic_searchable: true do |index|
        index.as :stored_searchable
      end

      property :license, advance_search: false, predicate: ::RDF::Vocab::CC.License, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      # End of normal properties
      # Controlled vocabulary terms
      property :creator, predicate: ::RDF::Vocab::DC11.creator, class_name: OregonDigital::ControlledVocabularies::Creator do |index|
        index.as :stored_searchable, :facetable
      end

      property :contributor, predicate: ::RDF::Vocab::DC11.contributor, class_name: OregonDigital::ControlledVocabularies::Creator do |index|
        index.as :stored_searchable, :facetable
      end

      property :institution, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/contributingInstitution'),
                             class_name: OregonDigital::ControlledVocabularies::Institution do |index|
        index.as :stored_searchable, :facetable
      end

      property :repository, predicate: ::RDF::Vocab::MARCRelators.rps,
                            class_name: OregonDigital::ControlledVocabularies::Repository do |index|
        index.as :stored_searchable, :facetable
      end

      property :publisher, predicate: ::RDF::Vocab::DC.publisher,
                           class_name: OregonDigital::ControlledVocabularies::Publisher do |index|
        index.as :stored_searchable, :facetable
      end

      property :subject, predicate: ::RDF::Vocab::DC.subject, class_name: OregonDigital::ControlledVocabularies::Subject do |index|
        index.as :stored_searchable, :facetable
      end

      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties

      # Sets controlled values
      self.controlled_properties = properties.select { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys.map(&:to_sym)

      # Allows for the controlled properties to accept nested data
      controlled_properties.each do |prop|
        accepts_nested_attributes_for prop, reject_if: id_blank, allow_destroy: true
      end

      # defines a method for Generic to be able to grab a list of properties
      define_singleton_method :controlled_property_labels do
        remote_controlled_props = controlled_properties.each_with_object([]) { |prop, array| array << "#{prop}_label" }
        file_controlled_props = %w[license_label]
        (remote_controlled_props + file_controlled_props).freeze
      end

      define_singleton_method :generic_properties do
        (properties.reject { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys - initial_properties)
      end

      ORDERED_PROPERTIES = [
        { name: 'alternative_title', is_controlled: false },
        { name: 'creator_label', is_controlled: true },
        { name: 'contributor_label', is_controlled: true },
        { name: 'date', is_controlled: false },
        { name: 'date_created', is_controlled: false },
        { name: 'subject_label', is_controlled: true },
        { name: 'license_label', is_controlled: true },
        { name: 'language_label', is_controlled: false, name_label: 'language' },
        { name: 'repository_label', is_controlled: true },
        { name: 'publisher_label', is_controlled: true },
        { name: 'has_finding_aid', is_controlled: false },
        { name: 'institution_label', is_controlled: true },
        { name: 'date_uploaded', is_controlled: false },
        { name: 'date_modified', is_controlled: false }
      ].freeze
    end
  end
end
