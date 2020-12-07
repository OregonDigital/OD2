# frozen_string_literal:true

# Added to allow for the My controller to show only things I have edit access to
class OregonDigital::NonUserCollectionsSearchBuilder < Hyrax::CollectionSearchBuilder
  include OregonDigital::OnlyNonUserCollectionsBehavior
  self.default_processor_chain += [:show_only_collections_not_created_users]
end
