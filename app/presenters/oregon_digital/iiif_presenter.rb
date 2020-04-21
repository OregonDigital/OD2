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

    def file_set_presenters
      presenters = []
      file_sets.each do |fs|
        urls = file_set_derivatives_service(fs).sorted_derivative_urls('jp2')

        urls.each_with_index do |derivative, i|
          label = urls.length > 1 ? page_label(fs.label, i) : fs.label
          presenters << JP2Presenter.new(fs, derivative, label, current_ability, request)
        end
      end

      presenters
    end

    def search_service
      'http://test.library.oregonstate.edu:3000' + Rails.application.routes.url_helpers.solr_document_iiif_search_path(solr_document_id: id.to_s)
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
  end
end
