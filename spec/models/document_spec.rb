# Generated via
#  `rails generate hyrax:work Document`
require 'rails_helper'

RSpec.describe Document do
  it "has video specific metadata properties" do
    %i[contained_in_journal first_line first_line_chorus has_number host_item instrumentation is_volume larger_work number_of_pages table_of_contents].each do |t|
      expect(described_class.attribute_names.map(&:to_sym)).to include(t)
    end
  end
end
