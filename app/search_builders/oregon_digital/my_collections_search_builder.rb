# frozen_string_literal:true

# Added to allow for the My controller to show only things I have edit access to
class OregonDigital::MyCollectionsSearchBuilder < Hyrax::My::CollectionsSearchBuilder
  # This overrides the models in Hyrax::My::CollectionsSearchBuilder
  # @return [Array<Class>] a list of classes to include
  def models
    [::Collection]
  end
end
