module Admin
  module ScholarsArchive
    # Extension of Hyrax CollectionTypesController to add facet_configurable to strong params
    class CollectionTypesController < Hyrax::Admin::CollectionTypesController

      self.form_class = ScholarsArchive::Forms::Admin::CollectionTypeForm

      private

      def collection_type_params
        params.require(:collection_type).permit(:title, :description, :nestable, :brandable, :discoverable, :sharable, :facet_configurable, :share_applies_to_new_works,
                                            :allow_multiple_membership, :require_membership, :assigns_workflow, :assigns_visibility, :badge_color)
      end
    end
  end
end
