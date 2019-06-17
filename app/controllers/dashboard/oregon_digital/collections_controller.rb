# frozen_string_literal:true

module Dashboard
  module OregonDigital
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::Dashboard::CollectionsController

      self.form_class = OregonDigital::Forms::CollectionForm
      self.presenter_class = OregonDigital::CollectionPresenter

      # Override update to add facet processing
      def update
        process_facets
        super
      end

      private

      # Turn form params into Facet objects
      def process_facets
        Rack::Utils.parse_nested_query(params[:facet_configuration])['facet'].each_with_index do |id, index|
          facet = Facet.find id
          facet.label = params["facet_label_#{id}"]
          facet.enabled = params["facet_enabled_#{id}"]
          facet.order = index
          facet.save
        end
      end
    end
  end
end
