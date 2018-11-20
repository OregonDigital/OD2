# Generated via
#  `rails generate hyrax:work Document`
require 'rails_helper'

RSpec.describe Hyrax::DocumentForm do
  let(:new_form) { described_class.new(Document.new, nil, double('Controller')) }
  let(:user) { create(:user) }
  let(:ability) { double('Ability') }

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it 'responds to terms with the proper list of terms' do
      %i[contained_in_journal first_line first_line_chorus has_number host_item instrumentation is_volume larger_work number_of_pages table_of_contents].each do |t|
      expect(described_class.terms).to include(t)
    end
  end
end
