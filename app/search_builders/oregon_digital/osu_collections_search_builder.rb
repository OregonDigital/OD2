# frozen_string_literal:true

# Added to allow for the My controller to show only things I have edit access to
class OregonDigital::OsuCollectionsSearchBuilder < OregonDigital::NonUserCollectionsSearchBuilder
  include OregonDigital::OnlyOsuCollectionsBehavior

  self.default_processor_chain += [:show_only_osu_collections]
end
