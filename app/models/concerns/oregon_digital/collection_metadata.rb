# frozen_string_literal:true

module OregonDigital
  # Sets metadata for a collection
  module CollectionMetadata
    extend ActiveSupport::Concern
    # Usage notes and expectations can be found in the Metadata Application Profile:
    # https://docs.google.com/spreadsheets/d/1ien3djlZxcctuAE99XweyuNdMiN5YsrKoYBJcK3DjLQ/edit?usp=sharing

    included do
      initial_properties = properties.keys
      property :alternative_title, predicate: ::RDF::Vocab::DC.alternative
      property :title, predicate: RDF::Vocab::DC.title, multiple: true, basic_searchable: true do |index|
        index.as :stored_searchable
      end

      property :creator, predicate: RDF::Vocab::DC11.creator, multiple: true, basic_searchable: true, class_name: OregonDigital::ControlledVocabularies::Creator do |index|
        index.as :stored_searchable, :facetable
      end

      property :contributor, predicate: RDF::Vocab::DC11.contributor, multiple: true, basic_searchable: true, class_name: OregonDigital::ControlledVocabularies::Creator do |index|
        index.as :stored_searchable, :facetable
      end

      property :description, predicate: RDF::Vocab::DC.description, multiple: true, basic_searchable: true do |index|
        index.as :stored_searchable
      end

      property :subject, predicate: RDF::Vocab::DC.subject, multiple: true, basic_searchable: true, class_name: OregonDigital::ControlledVocabularies::Subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :date, predicate: RDF::Vocab::DC.date, multiple: true, basic_searchable: true do |index|
        index.as :stored_searchable
      end

      property :date_created, predicate: RDF::Vocab::DC.created, multiple: true, basic_searchable: true do |index|
        index.as :stored_searchable
      end

      property :license, predicate: RDF::Vocab::CC.License, multiple: false, basic_searchable: true do |index|
        index.as :stored_searchable, :facetable
      end

      property :repository, predicate: RDF::Vocab::MARCRelators.rps, multiple: true, basic_searchable: true, class_name: OregonDigital::ControlledVocabularies::Repository do |index|
        index.as :stored_searchable, :facetable
      end

      property :language, predicate: RDF::Vocab::DC.language, multiple: true, basic_searchable: true do |index|
        index.as :stored_searchable, :facetable
      end

      property :publisher, predicate: RDF::Vocab::DC.publisher, multiple: true, basic_searchable: true, class_name: OregonDigital::ControlledVocabularies::Publisher do |index|
        index.as :stored_searchable, :facetable
      end

      property :has_finding_aid, predicate: RDF::URI.new('http://lod.xdams.org/reload/oad/has_findingAid'), multiple: true, basic_searchable: true do |index|
        index.as :stored_searchable
      end

      property :related_url, predicate: RDF::RDFS.seeAlso, multiple: true, basic_searchable: false do |index|
        index.as :stored_searchable
      end

      property :institution, predicate: RDF::URI.new('http://opaquenamespace.org/ns/contributingInstitution'), multiple: true, basic_searchable: true, class_name: OregonDigital::ControlledVocabularies::Institution do |index|
        index.as :stored_searchable, :facetable
      end

      # bulkrax shared system identifier
      property :source, predicate: ::RDF::Vocab::DC.source do |index|
        index.as :stored_searchable
      end

      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties

      # Sets controlled values
      self.controlled_properties = properties.select { |_k, v| v.class_name.nil? ? false : v.class_name.to_s.include?('ControlledVocabularies') }.keys.map(&:to_sym)

      # Allows for the controlled properties to accept nested data
      controlled_properties.each do |prop|
        accepts_nested_attributes_for prop, reject_if: id_blank, allow_destroy: true
      end

      # defines a method for Collection to be able to grab a list of properties
      define_singleton_method :controlled_property_labels do
        remote_controlled_props = controlled_properties.each_with_object([]) { |prop, array| array << "#{prop}_label" }
        file_controlled_props = %w[license_label]
        (remote_controlled_props + file_controlled_props).freeze
      end

      define_singleton_method :collection_properties do
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
        { name: 'related_url', is_controlled: false },
        { name: 'resource_type', is_controlled: true },
        { name: 'institution_label', is_controlled: true },
        { name: 'date_uploaded', is_controlled: false },
        { name: 'date_modified', is_controlled: false }
      ].freeze

      ORDERED_HEADER_PROPERTIES = [
        { name: 'title', is_controlled: false },
        { name: 'description', is_controlled: false },
        { name: 'date', is_controlled: false },
        { name: 'has_finding_aid', is_controlled: false }
      ].freeze

      ORDERED_FOOTER_PROPERTIES = ORDERED_PROPERTIES

      ORDERED_TERMS = %i[
        title
        creator
        contributor
        description
        subject
        date
        date_created
        license
        repository
        language
        publisher
        has_finding_aid
        related_url
        resource_type
        institution
      ].freeze
    end
  end
end
