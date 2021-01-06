# frozen_string_literal:true

# Added to allow for the My controller to show only UO items 
class OregonDigital::UoCollectionsSearchBuilder < OregonDigital::NonUserCollectionsSearchBuilder
  include OregonDigital::OnlyUoCollectionsBehavior
  self.default_processor_chain += [:show_only_uo_collections]
end
