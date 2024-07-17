# frozen_string_literal: true

module OregonDigital
  # adds parsable labels to indexers
  # moved from GenericIndexer
  module ParsableLabelBehavior
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # METHOD: Solrize 'label$uri' into Solr
    def label_fetch_properties_solr_doc(object, solr_doc)
      # LOOP: Go through the controlled properties to get the field needed for indexing
      object.controlled_properties.each do |o|
        # FETCH: Get the array of controlled vocab from the properties
        controlled_vocabs = object[o]

        # CREATE: Make an empty label array
        labels = []

        # LOOP: Loop through all controlled vocabs uri and solrize to make it into 'label$uri'
        controlled_vocabs.each do |cv|
          cv.fetch
          labels << (cv.solrize.last.is_a?(String) ? ['', cv.solrize.last].join('$') : cv.solrize.last[:label])
        rescue IOError, SocketError, TriplestoreAdapter::TriplestoreException
          labels << ['', cv.solrize.last].join('$')
        end

        # ASSIGN: Put the labels into their own field in solr_doc
        solr_doc["#{o}_parsable_label_ssim"] = labels

        # FETCH: Get the combined_properties from DeepIndex
        combined_label = rdf_indexer.combined_properties[o.to_s]
        next if combined_label.blank?

        # CREATE: Push item into the new field of combine labels
        index_parsable_combined_labels(combined_label, labels, solr_doc)
      end

      # ADD: Add keyword values to topic combined labels
      if object.respond_to? :keyword
        keyword_labels = object[:keyword].map { |kw| "#{kw}$" }
        index_parsable_combined_labels('topic', keyword_labels, solr_doc)
      end

      # RETURN: Return the solr 'label$uri' in their field
      solr_doc
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity

    # METHOD: Create the combined label parsable
    def index_parsable_combined_labels(label, values, solr_doc)
      solr_doc["#{label}_parsable_combined_label_ssim"] ||= []

      solr_doc["#{label}_parsable_combined_label_ssim"] += values
    end
  end
end
