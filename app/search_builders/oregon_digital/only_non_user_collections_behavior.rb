# frozen_string_literal:true

module OregonDigital
  # Behavior for surpressing user collections
  module OnlyNonUserCollectionsBehavior
    extend ActiveSupport::Concern

    included do
      def show_only_collections_not_created_users(solr_parameters)
        clauses = [
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(collection_type_gid: Hyrax::CollectionType.find_by(machine_id: :user_collection).to_global_id.to_s),
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(collection_type_gid: Hyrax::CollectionType.find_by(machine_id: :oai_set).to_global_id.to_s)
        ]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["!(#{clauses.join(' OR ')})"]
      end
    end
  end
end
