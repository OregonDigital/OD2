# frozen_string_literal:true

# Search Builder for the catalog
class OregonDigital::CatalogSearchBuilder < ::SearchBuilder
  include OregonDigital::OnlyNonUserCollectionsBehavior
  include OregonDigital::FilterTombstone
  self.default_processor_chain += %i(show_only_collections_not_created_users, non_tombstoned_works)
end
