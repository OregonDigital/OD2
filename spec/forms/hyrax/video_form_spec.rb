# frozen_string_literal:true

RSpec.describe Hyrax::VideoForm do
  let(:new_form) { described_class.new(Video.new, nil, instance_double('Controller')) }
  let(:user) { create(:user) }
  let(:ability) { instance_double('Ability') }
  let(:props) do
    Generic::ORDERED_TERMS
  end
  let(:terms) { new_form.primary_terms + new_form.secondary_terms }
  let(:model) { create(:video) }

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it 'responds to terms with the proper list of terms' do
    props.each do |t|
      expect(terms).to include(t)
    end
  end

  it 'matches terms to model properties' do
    terms.each do |term|
      expect(model).to respond_to(term)
    end
  end
end
