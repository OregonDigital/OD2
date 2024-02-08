# frozen_string_literal:true

module OregonDigital
  # Create report on facet values for migrated batch of assets
  class VerifyService
    def initialize(args)
      @work = args[:work]
      @solr_doc = args[:solr_doc]
    end

    def verify; end
  end
end
