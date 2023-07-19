# frozen_string_literal:true

module OregonDigital
  # IIIFPresenter wraps a work that needs to have all its JP2 derivatives
  # displayed in a viewer.  This overrides all the core Hyrax behaviors which
  # try to do IIIF magic (to get around the "one JP2 per fileset" assumption
  # Hyrax makes), but doesn't override any other presenter logic, and should
  # only be used for helping to build the IIIF manifest.
  class IIIFPresenter < Hyrax::WorkShowPresenter
    attr_accessor :file_sets
    attr_writer :collections
    delegate :id, to: :solr_document
    delegate(*Hyrax.config.iiif_metadata_fields, to: :solr_document)

    # Select out the metadata that doesn't have a value
    def manifest_metadata
      super.select { |m| m['value'].present? }
    end

    # rubocop:disable Metrics/AbcSize
    def file_set_presenters
      presenters = []
      file_sets.each do |fs|
        deriv_type, presenter_class = file_set_presenter_info fs

        urls = file_set_derivatives_service(fs).sorted_derivative_urls(deriv_type)

        urls.each_with_index do |derivative, i|
          label = urls.length > 1 ? page_label(fs.parents.first.title_or_label, i) : fs.parents.first.title_or_label
          presenters << presenter_class.new(fs, derivative, label, current_ability, request)
        end
      end

      presenters
    end
    # rubocop:enable Metrics/AbcSize

    # Determine which derivative type and IIIF fileset presenter to use
    def file_set_presenter_info(fs)
      if fs.video?
        ['mp4', MP4Presenter]
      elsif fs.image? || fs.pdf?
        ['jp2', JP2Presenter]
      elsif fs.audio?
        ['mp3', MP3Presenter]
      else
        ['jp2', JP2Presenter]
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def work_presenters
      work_ids = (ordered_ids - file_sets.map(&:id))
      return [] if work_ids.empty?

      solr_query = Hyrax::SolrQueryBuilderService.construct_query_for_ids(work_ids)
      solr_response = Hyrax::SolrService.get(solr_query, rows: 10_000)

      solr_response['response']['docs'].map do |doc|
        doc = SolrDocument.new(doc)
        presenter = IIIFPresenter.new(doc, current_ability, request)
        presenter.file_sets = doc.file_sets
        presenter.collections = cached_collections
        presenter
      end.sort_by(&:title)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def search_service
      [request.base_url, Rails.application.routes.url_helpers.solr_document_iiif_search_path(solr_document_id: id.to_s)].join
    end

    def viewing_hint
      'paged'
    end

    private

    def file_set_derivatives_service(file_set)
      OregonDigital::FileSetDerivativesService.new(file_set)
    end

    def page_label(_label, page_index)
      (page_index + 1).to_s
    end

    # Get collection titles for manifest metadata
    def collections
      cached_collections.select { |key, _val| key.in? solr_document.member_of_collection_ids }.values
    end

    # Fill @collections with a hash :id => :title if not set by #work_presenters
    def cached_collections
      @collections ||= {}
      # Get collections not in the cache
      new_cols = solr_document.member_of_collection_ids.reject { |c| c.in? @collections.keys }
      # Add collections to cache
      new_cols.each do |c|
        @collections[c] = SolrDocument.find(c).title.first
      end
      @collections
    end

    # Get file set format labels for manifest metadata
    def format_label
      solr_document.file_sets.map(&:format_label).compact
    end
  end
end
