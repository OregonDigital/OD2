# frozen_string_literal:true

module OregonDigital
  # Behavior for surpressing UO Collections
  module OnlyOsuCollectionsBehavior
    extend ActiveSupport::Concern

    included do
      def show_only_osu_collections(solr_parameters)
        clauses = [
          '(_query_:"{!raw f=institution_sim}https://id.loc.gov/authorities/names/n80017721")'
        ]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["(#{clauses.join(' AND ')})"]
      end
    end
  end
end
