# frozen_string_literal:true

module Hyrax
  class DocumentPresenter < Hyrax::GenericPresenter
    delegate(*OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym), to: :solr_document)
  end
end
