# Generated via
#  `rails generate hyrax:work Generic`
require 'rails_helper'

RSpec.describe Hyrax::GenericForm do
  let(:new_form) { described_class.new(Generic.new, nil, double('Controller')) }
  let(:user) do
    create(:user)
  end
  let(:ability) { double('Ability') }
  let(:props) {OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)}

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it 'responds to terms with the proper list of terms' do
    props.each do |t|
      expect(described_class.terms).to include(t)
    end
  end
end
