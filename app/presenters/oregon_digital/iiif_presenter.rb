# frozen_string_literal:true

module OregonDigital
  # IIIFPresenter wraps a work that needs to have all its JP2 derivatives
  # displayed in a viewer.  This overrides all the core Hyrax behaviors which
  # try to do IIIF magic (to get around the "one JP2 per fileset" assumption
  # Hyrax makes), but doesn't override any other presenter logic, and should
  # only be used for helping to build the IIIF manifest.
  class IIIFPresenter < Hyrax::WorkShowPresenter
    attr_accessor :file_sets
    delegate :id, to: :solr_document
    delegate(*Hyrax.config.iiif_metadata_fields, to: :solr_document)

    # Select out the metadata that doesn't have a value
    def manifest_metadata
      super.select { |m| m['value'].present? }
    end

    def file_set_presenters
      presenters = []
      file_sets.each do |fs|
        urls = file_set_derivatives_service(fs).sorted_derivative_urls('mp3')
        urls.each_with_index do |derivative, i|
          label = urls.length > 1 ? page_label(fs.label, i) : fs.label
          if fs.video?
            presenters << MP4Presenter.new(fs, derivative, label, current_ability, request)
          elsif fs.image?
            presenters << MP4Presenter.new(fs, derivative, label, current_ability, request)
          elsif fs.audio?
            presenters << MP3Presenter.new(fs, derivative, label, current_ability, request)
          else
            presenters << JP2Presenter.new(fs, derivative, label, current_ability, request)
          end
        end
      end

      presenters
    end

    def work_presenters
      presenters = []

      (ordered_ids - file_sets.map(&:id)).each do |work_id|
        work = ActiveFedora::Base.find(work_id)
        doc = SolrDocument.find(work_id)

        presenter = IIIFPresenter.new(doc, current_ability, request)
        presenter.file_sets = work.file_sets
        presenters << presenter
      end

      presenters
    end

    def search_service
      Rails.application.routes.url_helpers.solr_document_iiif_search_url(solr_document_id: id.to_s)
    end

    def viewing_hint
      'paged'
    end

    private

    def file_set_derivatives_service(file_set)
      OregonDigital::FileSetDerivativesService.new(file_set)
    end

    def page_label(label, page_index)
      addendum = "Page #{page_index + 1}"
      return addendum unless page_index.zero?

      label + ": #{addendum}"
    end

    # Get collection titles for manifest metadata
    def collections
      solr_document.member_of_collection_ids.map do |c|
        Collection.find(c).title.first
      end.compact
    end

    # Get file set format labels for manifest metadata
    def format_label
      solr_document.file_sets.map(&:format_label).compact
    end
  end
end
