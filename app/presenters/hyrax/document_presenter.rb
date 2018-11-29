# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  class DocumentPresenter < Hyrax::GenericPresenter
    delegate *OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym), to: :solr_document 
  end
end
