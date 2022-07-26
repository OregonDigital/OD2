# frozen_string_literal: true

# OAI Set
class OaiSet < BlacklightOaiProvider::SolrSet
  # OAI Set object
  class << self
    # The Solr repository object (optional)
    attr_accessor :repository

    # The search builder used to construct OAI queries (optional)
    attr_accessor :search_builder

    # The Solr fields to map to OAI sets. Must be indexed (optional)
    attr_accessor :fields

    # Return a Solr filter query given a set spec
    def from_spec(spec)
      raise OAI::ArgumentException unless ActiveFedora::SolrService.query("has_model_ssim:AdminSet AND id:#{spec}", rows: 1).count.positive?

      "isPartOf_ssim:#{spec}"
    end

    private

    def sets_from_facets(facets)
      sets = []
      facets.each do |_facet, terms|
        sets.concat(terms.each_slice(2).map { |t| new(t.first) })
      end
      sets.empty? ? nil : sets
    end
  end

  # OAI Set properties
  attr_accessor :spec, :name, :description

  # Build a set object with, at minimum, a set spec string
  def initialize(spec, opts = {})
    @spec = spec
    @name = opts[:name] || name_from_spec
    @description = opts[:description]
  end

  private

  def name_from_spec
    ActiveFedora::SolrService.query("has_model_ssim:AdminSet AND id:#{@spec}", rows: 1).first['title_tesim'].first
  end
end
