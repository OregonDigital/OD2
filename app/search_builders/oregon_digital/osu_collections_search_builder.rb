# frozen_string_literal:true

# Added to allow for the My controller to show only OSU items
class OregonDigital::OsuCollectionsSearchBuilder < OregonDigital::NonUserCollectionsSearchBuilder
  include OregonDigital::OnlyOsuCollectionsBehavior

  self.default_processor_chain += [:show_only_osu_collections]
end
