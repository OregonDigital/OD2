# frozen_string_literal:true

module OregonDigital
  # Behavior for surpressing UO Collections
  module OnlyOsuCollectionsBehavior
    extend ActiveSupport::Concern

    included do
      def show_only_osu_collections(solr_parameters)
        clauses = [
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(institution_label: 'Oregon State University')
        ]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["!(#{clauses.join(' OR ')})"]
      end
    end
  end
end
