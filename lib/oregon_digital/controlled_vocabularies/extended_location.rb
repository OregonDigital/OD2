# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Media Type object for storing labels and uris
    class ExtendedLocation < Hyrax::ControlledVocabularies::Location
      property :parentFeature, predicate: RDF::URI('http://www.geonames.org/ontology#parentFeature'), class_name: 'Hyrax::ControlledVocabularies::Location'
      property :parentCountry, predicate: RDF::URI('http://www.geonames.org/ontology#parentCountry'), class_name: 'Hyrax::ControlledVocabularies::Location'
      property :featureCode, predicate: RDF::URI('http://www.geonames.org/ontology#featureCode')
      property :featureClass, predicate: RDF::URI('http://www.geonames.org/ontology#featureClass')

      # Overrides rdf_label to recursively add location disambiguation when available.
      def rdf_label
        label = super

        unless parentFeature.empty? || RDF::URI(label.first).valid?
          #TODO: Identify more featureCodes that should cause us to terminate the sequence

          return label if top_level_element?

          parent_label = parentFeature.first.is_a? ActiveTriples::Resource ? parentFeature.first.rdf_label.first : []
          return label if parent_label.empty? || RDF::URI(parent_label).valid? || parent_label.starts_with?('_:')

          fc_label = OregonDigital::FeatureClassUriToLabel.new.uri_to_label(featureClass.first.id.to_s) unless featureClass.blank?
          label = "#{label.first} , #{parent_label} (#{fc_label}) " unless parent_label.include?('(')
          label = "#{label.first} , #{parent_label}".gsub(/\((.*)\)/, " (#{fc_label}) ") if parent_label.include?('(')
        end
        Array(label)
      end

      # Fetch parent features if they exist. Necessary for automatic population of rdf label.
      def fetch(headers)
        result = super(headers)
        return result if top_level_element?

        parentFeature.each do |feature|
          feature.fetch(headers)
        end
        result
      end

      # Persist parent features.
      def persist!
        result = super
        return result if top_level_element?

        parentFeature.each(&:persist!)
        result
      end

      def top_level_element?
        feature_code = featureCode.first
        top_level_codes = [RDF::URI('http://www.geonames.org/ontology#A.PCLI')]
        featureCode.respond_to?(:rdf_subject) && top_level_codes.include?(feature_code.rdf_subject)
      end
    end
  end
end
