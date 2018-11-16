require 'linkeddata' # we need all the linked data types, because we don't know what types a service might return.
module OD2
  class SaDeepIndexingService < Hyrax::DeepIndexingService
    self.stored_fields = stored_fields - [:related_url]
  end
end