class OregonDigital::CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  include OregonDigital::OnlyNonUserCollectionsBehavior
  self.default_processor_chain += [:show_only_collections_not_created_users]
end