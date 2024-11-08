# frozen_string_literal:true

module OregonDigital
  # Behavior for surpressing OSU Collections
  module OnlyUoCollectionsBehavior
    extend ActiveSupport::Concern

    included do
      def show_only_uo_collections(solr_parameters)
        clauses = [
          '(_query_:"{!raw f=institution_sim}https://id.loc.gov/authorities/names/n80126183")'
        ]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["(#{clauses.join(' AND ')})"]
      end
    end
  end
end
