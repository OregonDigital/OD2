# frozen_string_literal: true

module Hyrax
  module ControlledVocabularies
    # Location object
    class Location < ActiveTriples::Resource
      configure rdf_label: ::RDF::Vocab::GEONAMES.name

      attr_accessor :top_level_element

      property :parentADM1, predicate: RDF::URI('http://www.geonames.org/ontology#parentADM1'), class_name: Hyrax::ControlledVocabularies::Location
      property :parentADM2, predicate: RDF::URI('http://www.geonames.org/ontology#parentADM2'), class_name: Hyrax::ControlledVocabularies::Location
      property :parentADM3, predicate: RDF::URI('http://www.geonames.org/ontology#parentADM3'), class_name: Hyrax::ControlledVocabularies::Location
      property :parentADM4, predicate: RDF::URI('http://www.geonames.org/ontology#parentADM4'), class_name: Hyrax::ControlledVocabularies::Location
      property :parentCountry, predicate: RDF::URI('http://www.geonames.org/ontology#parentCountry'), class_name: Hyrax::ControlledVocabularies::Location
      property :featureCode, predicate: RDF::URI('http://www.geonames.org/ontology#featureCode')

      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label_uri_same?

        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      # Overrides rdf_label to add location disambiguation when available.
      def rdf_label
        @label = super

        unless valid_label
          return Array("#{@label.first} County") if us_county? && no_county_label
          return @label if top_level_element?

          @label = @label.first
          parent_hierarchy.each do |p|
            @label = "#{@label} >> #{p.first.rdf_label.first}"
          end
        end
        Array(@label)
      end

      # Fetch parent features if they exist. Necessary for automatic population of rdf label.
      def fetch(*_args, &_block)
        resource = super
        return resource if top_level_element?

        parent_hierarchy.each do |p|
          p.first.top_level_element = true
          p.first.fetch
        end
        resource
      end

      # Persist parent features.
      def persist!
        result = super
        return result if top_level_element?

        parent_hierarchy.each do |p|
          p.first.persist!
        end

        result
      end

      private

      # Identify if this is a county in the USA
      def us_county?
        feature_code = featureCode.first
        parent_country = parentCountry.first
        sec_adm_level_code = 'www.geonames.org/ontology#A.ADM2'
        us_country_code = 'sws.geonames.org/6252001/'
        feature_code.respond_to?(:rdf_subject) && feature_code.rdf_subject.to_s.include?(sec_adm_level_code) && parent_country.respond_to?(:rdf_subject) && parent_country.rdf_subject.to_s.include?(us_country_code)
      end

      def no_county_label
        !@label.first.downcase.include?('county')
      end

      # Administrative hierarchy values
      def parent_hierarchy
        [
          parentADM4,
          parentADM3,
          parentADM2,
          parentADM1,
          parentCountry
        ].reject(&:empty?)
      end

      def rdf_label_uri_same?
        rdf_label.first.to_s == rdf_subject.to_s
      end

      def valid_label
        RDF::URI(@label.first).valid?
      end

      def top_level_element?
        @top_level_element ||= false
      end
    end
  end
end
