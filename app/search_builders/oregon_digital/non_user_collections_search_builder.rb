# frozen_string_literal:true

# Added to allow for the My controller to show only things I have edit access to
class OregonDigital::NonUserCollectionsSearchBuilder < Hyrax::CollectionSearchBuilder
  self.default_processor_chain += [:show_only_collections_not_created_users]

  def show_only_collections_not_created_users(solr_parameters)
    clauses = [
      ActiveFedora::SolrQueryBuilder.construct_query_for_rel(collection_type_gid: Hyrax::CollectionType.find_by(machine_id: :user_collection).gid)
    ]
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += ["!(#{clauses.join(' OR ')})"]
  end
end
