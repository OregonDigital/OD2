# Generated via
#  `rails generate hyrax:work Generic`
module Hyrax
  class GenericPresenter < Hyrax::WorkShowPresenter
    delegate :oembed_url, to: :solr_document
  end
end
