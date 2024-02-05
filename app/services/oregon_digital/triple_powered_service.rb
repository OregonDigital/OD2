# frozen_string_literal: true

require 'triplestore_adapter'

module OregonDigital
  # Triple Powered Service to fetch out data from uri and grouped as 'label$uri'
  class TriplePoweredService
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # METHOD: A check function to identify if date fetch need to happen or not and fetch the top label first
    def check_and_fetch_label(uris, parse_date: false)
      if parse_date
        fetch_all_labels_with_date(uris).first
      else
        fetch_all_labels(uris).first
      end
    end

    # METHOD: Functionality to fetch all labels and put it as 'label$uri'
    def fetch_all_labels(uris)
      labels = []
      uris.each do |uri|
        graph = fetch_from_store(uri)
        labels << predicate_labels(graph).values.flatten.compact.collect { |label| "#{label}$#{uri}" }
      end
      labels.flatten.compact
    end

    # METHOD: Functionality to fetch all labels w/ date format and put it as 'label$uri'
    def fetch_all_labels_with_date(uris)
      labels = []
      uris.each do |uri|
        graph = fetch_from_store(uri)
        values = predicate_label_dates(graph).values.flatten.compact
        labels << if values.size.positive?
                    values.collect { |label_date| "#{label_date}$#{uri}" }
                  else
                    predicate_labels(graph).values.flatten.compact.collect { |label| "#{label}$#{uri}" }
                  end
      end
      labels.flatten.compact
    end

    private

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    # METHOD: Fetch label from graph
    def predicate_labels(graph)
      labels = {}
      return labels if graph.nil?

      rdf_label_predicates.each do |predicate|
        # GET: Fetch all the labels
        all_labels = graph
                     .query(predicate: predicate)
                     .reject { |statement| statement.is_a?(Array) }
                     .map(&:object)

        # ASSIGN: Assign all the labels to the labels arr
        labels[predicate.to_s] = all_labels.map(&:to_s)
        # SELECT: Go through all labels and sort out all that has english label
        eng_labels = all_labels
                     .select { |value| value.respond_to?(:language) ? value.language.in?(%i[en en-us]) : true }
        # CHECK: Assign the english label and check the english label
        labels[predicate.to_s] = eng_labels.map(&:to_s) if eng_labels.count.positive?
        labels[predicate.to_s].compact!
      end
      labels
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # METHOD: Fetch label from graph w/ date
    def predicate_label_dates(graph)
      label_dates = {}
      return label_dates if graph.nil?

      rdf_label_predicates.each do |predicate|
        # GET: Fetch all the labels w/ dates
        label_dates[predicate.to_s] = []
        label_dates[predicate.to_s] << label_dates_query(graph, predicate)
                                       .reject { |statement| statement.is_a?(Array) }
                                       .map { |statement| "#{statement.label} - #{statement.date}" }
        label_dates[predicate.to_s].flatten!.compact!
      end
      label_dates
    end

    # METHOD: Special method to get label date
    def label_dates_query(graph, label_predicate)
      patterns = {
        label_date: {
          label_predicate => :label,
          RDF::Vocab::DC.date => :date
        }
      }
      query = RDF::Query.new(patterns)
      query.execute(graph).to_a
    end

    # METHOD: A function holding all predicate for label
    def rdf_label_predicates
      [
        RDF::Vocab::SKOS.prefLabel,
        RDF::Vocab::DC.title,
        RDF::Vocab::RDFS.label,
        RDF::Vocab::SKOS.altLabel,
        RDF::Vocab::SKOS.hiddenLabel
      ]
    end

    # rubocop:disable Style/GuardClause
    # METHOD: Using Triple Store to fetch the information from URI
    def fetch_from_store(uri)
      unless uri.blank?
        begin
          @triplestore ||= TriplestoreAdapter::Triplestore.new(TriplestoreAdapter::Client.new(ENV['TRIPLESTORE_ADAPTER_TYPE'] || 'blazegraph',
                                                                                              ENV['TRIPLESTORE_ADAPTER_URL'] || 'http://blazegraph-dev:8080/bigdata/namespace/kb/sparql'))
          @triplestore.fetch(uri, from_remote: true)
        rescue TriplestoreAdapter::TriplestoreException => e
          Rails.logger.warn e.message
          nil
        end
      end
    end
    # rubocop:enable Style/GuardClause
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
