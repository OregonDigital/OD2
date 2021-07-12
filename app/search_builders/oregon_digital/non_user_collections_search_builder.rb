# frozen_string_literal:true

# Added to allow for the My controller to show only things I have edit access to
class OregonDigital::NonUserCollectionsSearchBuilder < Hyrax::CollectionSearchBuilder
  include OregonDigital::OnlyNonUserCollectionsBehavior
  self.default_processor_chain += [:show_only_collections_not_created_users]

  # OVERRIDE FROM BLACKLIGHT https://github.com/projectblacklight/blacklight/blob/v6.23.0/lib/blacklight/search_builder.rb#L187-L190
  # Removes per_page limit to rows maximum value
  def rows=(value)
    params_will_change!
    @rows = value.to_i
  end
end
