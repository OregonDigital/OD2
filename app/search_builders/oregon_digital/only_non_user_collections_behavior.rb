# frozen_string_literal:true

module OregonDigital
  # Behavior for surpressing user collections
  module OnlyNonUserCollectionsBehavior
    extend ActiveSupport::Concern

    included do
      def show_only_collections_not_created_users(solr_parameters)
        clauses = [
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(collection_type_gid: Hyrax::CollectionType.find_by(machine_id: :user_collection).gid)
        ]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["!(#{clauses.join(' OR ')})"]
        solr_parameters[:rows] = 1000
      end
    end
  end
end
