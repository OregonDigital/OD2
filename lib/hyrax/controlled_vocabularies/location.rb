# frozen_string_literal: true

module Hyrax
  module ControlledVocabularies
    # Location object
    class Location < ActiveTriples::Resource
      configure rdf_label: ::RDF::Vocab::GEONAMES.name

      property :parentFeature, predicate: RDF::URI('http://www.geonames.org/ontology#parentFeature'), class_name: 'Hyrax::ControlledVocabularies::Location'
      property :parentCountry, predicate: RDF::URI('http://www.geonames.org/ontology#parentCountry'), class_name: 'Hyrax::ControlledVocabularies::Location'
      property :featureCode, predicate: RDF::URI('http://www.geonames.org/ontology#featureCode')
      property :featureClass, predicate: RDF::URI('http://www.geonames.org/ontology#featureClass')

      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label_uri_same?

        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      # Overrides rdf_label to recursively add location disambiguation when available.
      def rdf_label
        @label = super

        unless valid_label_without_parent
          return @label if top_level_element?

          parent_label = label_or_blank
          return @label if top_level_parent(parent_label)

          fc_label = OregonDigital::FeatureClassUriToLabel.new.uri_to_label(featureClass.first.id.to_s) unless featureClass.blank?
          build_label(parent_label, fc_label)
        end
        Array(@label)
      end

      # Fetch parent features if they exist. Necessary for automatic population of rdf label.
      def fetch(*_args, &_block)
        resource = super
        return resource if top_level_element?

        parentFeature.each(&:fetch)
        resource
      end

      # Persist parent features.
      def persist!
        result = super
        return result if top_level_element?

        parentFeature.each(&:persist!)
        result
      end

      private

      def rdf_label_uri_same?
        rdf_label.first.to_s == rdf_subject.to_s
      end

      def top_level_parent(parent_label)
        valid_or_blank_parent?(parent_label) || parent_label.starts_with?('_:')
      end

      def valid_label_without_parent
        parentFeature.empty? || RDF::URI(@label.first).valid?
      end

      def label_or_blank
        parentFeature.first.is_a?(ActiveTriples::Resource) ? parentFeature.first.rdf_label.first : []
      end

      def build_label(parent_label, fc_label)
        if parent_label.include?('(')
          set_location_label(@label, parent_label.gsub(/(, )?\((.*)\)/, ''), fc_label)
        else
          set_location_label(@label, parent_label, fc_label)
        end
      end

      def set_location_label(label, parent_label, fc_label)
        @label = "#{label.first}, #{parent_label}, (#{fc_label})"
      end

      def valid_or_blank_parent?(parent_label)
        parent_label.empty? || RDF::URI(parent_label).valid?
      end

      def top_level_element?
        feature_code = featureCode.first
        top_level_codes = [RDF::URI('http://www.geonames.org/ontology#A.PCLI'), RDF::URI('https://www.geonames.org/ontology#A.PCLI')]
        feature_code.respond_to?(:rdf_subject) && top_level_codes.include?(feature_code.rdf_subject)
      end
    end
  end
end
