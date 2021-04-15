# frozen_string_literal:true

module Hyrax
  # Behavior to configure review queue catalog
  module Admin
    module WorkflowsCatalogBehavior
      extend ActiveSupport::Concern
      include Hydra::Catalog
      include Hydra::Controller::ControllerBehavior
      include OregonDigital::BlacklightConfigBehavior

      included do
        def self.local_prefixes
          super + ['catalog']
        end

        configure_blacklight do |config|
          config.search_builder_class = OregonDigital::InReviewSearchBuilder
        end
      end
    end
  end
end
