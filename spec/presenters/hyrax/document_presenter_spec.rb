# Generated via
#  `rails generate hyrax:work Document`
require 'rails_helper'

RSpec.describe Hyrax::DocumentPresenter do
  subject { described_class.new(double, double) }

  %i[contained_in_journal first_line first_line_chorus has_number host_item instrumentation is_volume larger_work number_of_pages table_of_contents].each do |t|
    it { is_expected.to delegate_method(t).to(:solr_document) }
  end
end
