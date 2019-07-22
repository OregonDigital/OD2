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

    # OVERRIDEN FROM HYRAX TO ADD GRAPH FETCH RETRY QUEUE
    def fetch_value(value)
      Rails.logger.info "Fetching #{value.rdf_subject} from the authorative source. (this is slow)"
      value.fetch(headers: { 'Accept' => default_accept_header })
    rescue Net::ReadTimeout, IOError, SocketError, TriplestoreAdapter::TriplestoreException => e
      # IOError could result from a 500 error on the remote server
      # SocketError results if there is no server to connect to
      Rails.logger.error "Unable to fetch #{value.rdf_subject} from the authorative source.\n#{e.message}"
      object.graph_fetch_failures << value.rdf_subject
    end
  end
end
