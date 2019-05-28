# frozen_string_literal: true

module OregonDigital
  module Forms
    module Admin
      # Collection Type Form Object
      class CollectionTypeForm < Hyrax::Forms::Admin::CollectionTypeForm
        delegate :facet_configurable, to: :collection_type
      end
    end
  end
end
