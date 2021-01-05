# frozen_string_literal:true

# Added to allow for the My controller to show only things I have edit access to
class OregonDigital::OsuCollectionsSearchBuilder < OregonDigital::NonUserCollectionsSearchBuilder 
  self.default_processor_chain += []
end
