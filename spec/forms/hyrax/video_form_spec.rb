# Generated via
#  `rails generate hyrax:work Video`
require 'rails_helper'

RSpec.describe Hyrax::VideoForm do
  let(:new_form) { described_class.new(Video.new, nil, double('Controller')) }
  let(:user) do
    User.new(email: 'test@example.com', guest: false) { |u| u.save!(validate: false) }
  end
  let(:ability) { double('Ability') }

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it 'responds to terms with the proper list of terms' do
      %i[height width].each do |t|
      expect(described_class.terms).to include(t)
    end
  end
end
