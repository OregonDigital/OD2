# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  class DocumentPresenter < Hyrax::WorkShowPresenter
    delegate :contained_in_journal, :first_line, :first_line_chorus, :has_number,
             :host_item, :instrumentation, :is_volume, :larger_work, :number_of_pages,
             :table_of_contents,
    to: :solr_document
  end
end
