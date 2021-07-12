# frozen_string_literal: true

module BlacklightIiifSearch
  # IiifSearch
  class IiifSearch
    include BlacklightIiifSearch::SearchBehavior

    attr_reader :id, :iiif_config, :parent_document, :q, :page, :rows

    ##
    # @param [Hash] params
    # @param [Hash] iiif_search_config
    # @param [SolrDocument] parent_document
    def initialize(params, iiif_search_config, parent_document)
      @id = params[:solr_document_id]
      @iiif_config = iiif_search_config
      @parent_document = parent_document
      @q = params[:q]
      @page = params[:page]
      @rows = 50

      # NOT IMPLEMENTED YET
      # @motivation = params[:motivation]
      # @date = params[:date]
      # @user = params[:user]
    end

    ##
    # return a hash of Solr search params
    # if q is not supplied, have to pass some dummy params
    # or else all records matching object_relation_solr_params are returned
    # @return [Hash]
    def solr_params
      return { q: 'nil:nil' } unless q

      ids = parent_document.member_ids
      ids << id
      # OVERRIDE FROM BLACKLIGHT_IIIF_SEARCH to make the solr query join work with fileset documents
      { q: q, fq: ["{!join from=file_set_ids_ssim to=id}id:#{ids.join ' OR id:'}"], rows: rows, page: page }
    end
  end
end
