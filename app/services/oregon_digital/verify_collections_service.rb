# frozen_string_literal:true

module OregonDigital
  ##
  # A service to verify that collections have been set on works
  class VerifyCollectionsService < VerifyService
    attr_reader :verification_errors

    def verify
      @verification_errors = { collections: [] }
      @verification_errors[:collections] << 'no colls found' if no_colls?
      @verification_errors[:collections] << 'SOLR discrepancy' if colls_missing_in_index?
      @verification_errors
    end

    # rubocop:disable Style/SymbolProc
    def coll_ids
      @work.member_of_collection_ids.map { |x| x.id }
    end
    # rubocop:enable Style/SymbolProc

    def no_colls?
      coll_ids.blank?
    end

    def colls_missing_in_index?
      return false if no_colls?

      @solr_doc['member_of_collection_ids_ssim'].nil? ||
        @solr_doc['member_of_collection_ids_ssim'].sort != coll_ids.sort
    end
  end
end
