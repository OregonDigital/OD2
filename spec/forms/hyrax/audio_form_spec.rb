# Generated via
#  `rails generate hyrax:work Audio`
require 'rails_helper'

RSpec.describe Hyrax::AudioForm do
  let(:new_form) { described_class.new(Audio.new, nil, double('Controller')) }
  let(:user) { create(:user) }
  let(:ability) { double('Ability') }
  let(:props) {OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)}

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it "responds to terms with the proper list of terms" do
    props.each do |prop|
      expect(described_class.terms).to include(prop)
    end
  end
end
