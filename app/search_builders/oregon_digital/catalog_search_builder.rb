# frozen_string_literal:true

# Search Builder for the catalog
class OregonDigital::CatalogSearchBuilder < ::SearchBuilder
  include OregonDigital::OnlyNonUserCollectionsBehavior
  self.default_processor_chain += [:show_only_collections_not_created_users]
end
