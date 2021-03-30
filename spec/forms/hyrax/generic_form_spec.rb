# frozen_string_literal:true

RSpec.describe Hyrax::GenericForm do
  let(:new_form) { described_class.new(Generic.new, nil, instance_double('Controller')) }
  let(:user) { create(:user) }
  let(:ability) { instance_double('Ability') }
  let(:props) { Generic::ORDERED_TERMS }
  let(:terms) { new_form.primary_terms + new_form.secondary_terms }
  let(:model) { create(:generic) }

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  xit 'responds to terms with the proper list of terms' do
    props.each do |t|
      expect(terms).to include(t)
    end
  end

  xit 'matches terms to model properties' do
    terms.each do |term|
      expect(model).to respond_to(term)
    end
  end
end
