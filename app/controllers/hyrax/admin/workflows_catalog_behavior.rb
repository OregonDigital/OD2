# frozen_string_literal:true

module Hyrax
  module Admin
    # Behavior to configure review queue catalog
    module WorkflowsCatalogBehavior
      extend ActiveSupport::Concern
      include BlacklightAdvancedSearch::Controller
      include Hydra::Catalog
      include Hydra::Controller::ControllerBehavior
      include OregonDigital::BlacklightConfigBehavior

      included do
        # Add the 'catalog' folder to where views are looked for
        # This allows us to render blacklight/catalog views from the hyrax/admin/workflows folder
        def self.local_prefixes
          super + ['catalog']
        end

        configure_blacklight do |config|
          # Set the search builder for this search interface so only in-review works show up
          config.search_builder_class = OregonDigital::InReviewSearchBuilder
        end
      end
    end
  end
end
