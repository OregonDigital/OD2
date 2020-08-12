# frozen_string_literal: true

# OVERRIDDEN FROM HYRAX TO REMOVE UNUSED FIELDS
require 'linkeddata'
module OregonDigital
  # Used to index linked data
  class DeepIndexingService < Hyrax::DeepIndexingService
    class_attribute :stored_and_facetable_fields, :stored_fields, :symbol_fields
    self.stored_and_facetable_fields = %i[]
    self.stored_fields = %i[]
    self.symbol_fields = %i[]

    private

    # OVERRIDEN FROM HYRAX TO BYPASS THE FETCHING OF CONTROLLED VOCABULARIES
    def fetch_external
      object.controlled_properties.each do |property|
        object[property].each do |value|
          resource = value.respond_to?(:resource) ? value.resource : value
          next unless resource.is_a?(ActiveTriples::Resource)

          next if value.is_a?(ActiveFedora::Base)

          # Fetch if the vocab is cached since this is fast and can be displayed quicker.
          fetch_with_persistence(resource) if (!resource.class.include?(Location) && resource.in_triplestore?)
        end
      end
    end
  end
end
