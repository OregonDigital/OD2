# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
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

        fetch
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      # Overrides rdf_label to add location disambiguation when available.
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def rdf_label
        return rdf_ons_label unless geonames?

        @label = super
        @label = Array("#{@label.first} County") if us_county? && no_county_label

        unless valid_label
          return @label if top_level_element?

          @label = @label.first
          parent_hierarchy.each do |p|
            p.each do |loc|
              @label = "#{@label} >> #{loc.rdf_label.first}"
            end
          end
          # Get all county names
          counties = @label.split('>>').select { |c| c.include? ' County' }.sort.map(&:strip)
          # Sort and Combine county names + append "County/Counties"
          counties = counties.join('/').gsub(' County', '') + ' County'.pluralize(counties.count)
          # Pad the county string
          counties = " #{counties.strip} "
          # Replace old counties with new county string and squash down to one whole string
          @label = @label.split('>>').map { |c| c.include?(' County') ? counties : c }.uniq.join('>>').strip
        end
        Array(@label)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # ActiveTriples just grabs the first label
      # This is typically fine because it will find the preferred label first
      # But sometimes the first preferred label isn't in english, or all aren't
      # Disable rubocop because just barely fails abcsize
      # rubocop:disable Metrics/AbcSize
      def rdf_ons_label
        labels = Array.wrap(self.class.rdf_label)
        labels += default_labels
        # OVERRIDE from rdf_triples to select only and all english labels
        values = []
        labels.each do |label|
          values += get_values(label).to_a
        end
        eng_values = values.select { |val| val.language.in? %i[en en-us] if val.is_a?(RDF::Literal) }
        # We want English first
        return eng_values unless eng_values.blank?

        # But we'll take non-english if that's all there is
        return values unless values.blank?

        node? ? [] : [rdf_subject.to_s]
      end
      # rubocop:enable Metrics/AbcSize

      def fetch_from_cache(subject)
        OregonDigital::Triplestore.fetch_cached_term(subject)
      end

      def store_graph
        OregonDigital::Triplestore.triplestore_client.provider.insert(persistence_strategy.graph)
      end

      # Fetch parent features if they exist. Necessary for automatic population of rdf label.
      def fetch(*_args, &_block)
        graph = fetch_from_cache(rdf_subject)
        unless graph.nil?
          persistence_strategy.graph = graph
          fetch_parents unless top_level_element?
          return self
        end
        resource = super
        fetch_parents unless top_level_element?
        store_graph
        resource
      end

      def fetch_parents
        parent_hierarchy.each do |p|
          p.each do |loc|
            loc.top_level_element = true
            loc.fetch
          end
        end
      end

      # Persist parent features.
      def persist!
        result = super
        return result if top_level_element?

        parent_hierarchy.each do |p|
          p.each(&:persist!)
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

      def geonames?
        id.include? 'geonames.org'
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
