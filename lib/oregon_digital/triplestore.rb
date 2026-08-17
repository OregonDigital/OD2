# frozen_string_literal:true

require 'triplestore_adapter'

module OregonDigital
  # Configuration to allow connection to triplestore
  class Triplestore
    ##
    # Query the graph found at the supplied uri
    #
    # @param uri [String] the uri for the graph
    # @return [RDF::Graph] the graph
    def self.fetch(uri)
      return if uri.blank?

      @triplestore ||= TriplestoreAdapter::Triplestore.new(triplestore_client)
      begin
        graph = fetch_from_cache(uri, @triplestore)
      rescue TriplestoreAdapter::TriplestoreException
        graph = fetch_from_source(uri, @triplestore)
      end
      graph
    end

    def self.triplestore_client
      TriplestoreAdapter::Client.new(ENV['TRIPLESTORE_ADAPTER_TYPE'], ENV['TRIPLESTORE_ADAPTER_URL'])
    end

    def self.fetch_cached_term(uri)
      return if uri.blank?

      @triplestore ||= TriplestoreAdapter::Triplestore.new(triplestore_client)
      # Returns nil if it doesn't exist in triplestore
      @triplestore.fetch_cached_graph(uri)
    end

    ##
    # Common predicates which represent labels in a graph
    def self.rdf_label_predicates
      [RDF::Vocab::SKOS.prefLabel,
       RDF::Vocab::DC.title,
       RDF::Vocab::RDFS.label,
       RDF::Vocab::SKOS.altLabel,
       RDF::Vocab::SKOS.hiddenLabel]
    end

    ##
    # Returns an array of the labels found in the supplied graph
    #
    # @param graph [RDF::Graph] the graph
    # @return [Hash<String,Array<String>>] the labels
    def self.predicate_labels(graph)
      labels = {}
      return labels if graph.nil?

      rdf_label_predicates.each do |predicate|
        labels[predicate.to_s] = []
        labels[predicate.to_s] << fetched_graph(predicate, graph)
        labels[predicate.to_s].flatten!.compact!
      end
      labels
    end

    def self.fetched_graph(predicate, graph)
      graph.query(predicate: predicate).reject { |statement| statement.is_a?(Array) }.map { |statement| statement.object.to_s }
    end

    def self.fetch_from_cache(uri, triplestore)
      Rails.logger.info "Attempting to fetch #{uri} from local graph cache."
      # CONDITION: Check on one of the CV is Homosaurus or BNE
      graph = if uri.to_s.include?('homosaurus') || uri.to_s.include?('datos.bne.es')
                triplestore.fetch(uri + '.jsonld', from_remote: false)
              else
                triplestore.fetch(uri, from_remote: false)
              end
      Rails.logger.info 'Fetched From Cache'
      graph
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.fetch_from_source(uri, triplestore)
      Rails.logger.info "Fetching #{uri} from the external source. (this is slow)"
      Rails.logger.info "Checking Rails cache for prior failed external fetch: #{uri}"
      cache_check = Rails.cache.read(uri)
      return nil if cache_check == 'failed'

      begin
        # CONDITION: Check on one of the CV is Homosaurus or BNE
        graph = if uri.to_s.include?('homosaurus') || uri.to_s.include?('datos.bne.es')
                  triplestore.fetch(uri + '.jsonld', from_remote: true)
                else
                  triplestore.fetch(uri, from_remote: true)
                end
        Rails.logger.info "Fetch successful from external source: #{uri}"
        graph
      rescue TriplestoreAdapter::TriplestoreException
        Rails.logger.warn "Fetch failed from external source: #{uri}"
        Rails.cache.write(uri, 'failed', expires_in: ENV.fetch('FETCH_EXTERNAL_FAILED_WAIT', 1.week).to_i)
        raise TriplestoreAdapter::TriplestoreException
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # METHOD: Create a method store all fails CV fetch
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.store_failed_fetch(id, failed_cv)
      # PATH: Setup a path for the txt file
      path = Rails.root.join('tmp', 'shared', 'failed_fetch', "#{id}.txt").to_s

      # SEARCH: Look for works to create a link & get URL path
      work = SolrDocument.find(id)
      url_path = Rails.application.routes.url_helpers.polymorphic_url(work)

      # STORE: Add in data to txt file & check on exist file
      File.open(path, File.exist?(path) ? 'a' : 'w+') do |f|
        f.puts('Failed Fetch Record')
        f.puts("Work ID: #{id}")
        f.puts("Work Link: #{url_path}")
        failed_cv.each do |w|
          f.puts("Error Placement: #{w[:uri]}   Error on Value: #{w[:error]}")
        end
        f.puts("Time Recorded: #{Time.now.strftime('%m-%d-%Y %I:%M %p')}")
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # METHOD: Create and check exist of folder
    def self.create_and_check_directory
      dir_path = Rails.root.join('tmp', 'shared', 'failed_fetch').to_s
      FileUtils.mkdir_p(dir_path)
    end
  end
end
