# frozen_string_literal:true

module Hyrax
  class GenericPresenter < Hyrax::WorkShowPresenter
    delegate(*OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym), to: :solr_document)
  end
end
