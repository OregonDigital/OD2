# frozen_string_literal:true

module Hyrax
  # Display config for document object
  class DocumentPresenter < Hyrax::GenericPresenter
    delegate(*Document.document_properties.map(&:to_sym), to: :solr_document)
  end
end
