module Dashboard
  module OregonDigital
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::Dashboard::CollectionsController

      def update
        process_facets
        super
      end

      private

        def process_facets
        end
    end
  end
end
