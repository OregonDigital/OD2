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
      _, value = spec.split(':', 2)
      value = spec if value.nil?
      raise OAI::ArgumentException unless Hyrax::SolrService.query("has_model_ssim:Collection AND id:#{value}", rows: 1).count.positive?

      "member_of_collection_ids_ssim:#{value}"
    end

    def sets_for(record)
      Array.wrap(@fields).map do |field|
        record.fetch(field[:solr_field], []).map do |value|
          new(value.to_s)
        end
      end.flatten
    end

    private

    def sets_from_facets(facets)
      sets = []
      facets.each do |_facet, terms|
        sets.concat(terms.each_slice(2).map { |t| new(t.first) })
      end
      sets = sets.reject { |set| set.name.nil? }
      sets.empty? ? nil : sets
    end
  end

  # OAI Set properties
  attr_accessor :spec, :name, :description

  # Build a set object with, at minimum, a set spec string
  def initialize(spec, opts = {})
    @label, @value = spec.split(':', 2)
    @value = spec if @value.nil?
    @spec = spec
    @name = opts[:name] || name_from_spec
    @description = opts[:description]
  end

  private

  def name_from_spec
    collection = Collection.find @value
    return nil if collection.collection_type.gid != Hyrax::CollectionType.find_by(machine_id: :oai_set).gid.to_s

    Hyrax::SolrService.query("id:#{@value}", rows: 1).first['title_tesim'].first
  end
end
