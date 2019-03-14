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
  end
end
